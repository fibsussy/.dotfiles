//! PipeWire Links Manager
//!
//! Declarative audio/MIDI wiring for this machine:
//!
//!   Komplete mic -> micproc (processed) -> the "vmic" app feed (so apps
//!     record it)
//!   vmic monitor -> the default speaker device (so you hear your voice
//!     mixed with whatever apps play; if the default speaker IS the vmic,
//!     its connections are left alone)
//!   apps -> the default speaker device (WirePlumber's normal routing; the
//!     mic arrives there through the vmic-monitor tap)
//!   Oxygen 49 MIDI -> fluidsynth (on-demand) -> the "vmic" app feed
//!   ~/Soundboard/play.sh -> the default speaker device
//!
//! The routing is described by the `routes()` table, the vmic-monitor rule
//! and the synth rule. The engine does the rest: every poll it enumerates the
//! live graph, creates any link a rule declares but that isn't there yet, and
//! tears down links a rule doesn't declare on ports it owns.
//!
//! Compiled as a real release binary (was previously run through
//! `rust-script`); see `systemd/user/pipewire-links.service`.

use std::collections::HashSet;
use std::process::{Child, ChildStdin, Command, Stdio};
use std::thread;
use std::time::Duration;

// ────────────────────────────────────────────────────────────────────
// TIMING
// ────────────────────────────────────────────────────────────────────

const POLL_INTERVAL: Duration = Duration::from_secs(2);
const STARTUP_DELAY: Duration = Duration::from_secs(3);
const LINK_ATTEMPTS: u32 = 10;
const LINK_RETRY_DELAY: Duration = Duration::from_millis(500);

// ────────────────────────────────────────────────────────────────────
// NODE NAMES & THE SYNTH
// ────────────────────────────────────────────────────────────────────

const NAME_MIC: &str = "Komplete";
const NAME_MICPROC: &str = "micproc";
const NAME_VMIC: &str = "vmic";
// Matches the synth's single JACK node ("fluidsynth-midi": MIDI-in port +
// audio-out ports on one node), as well as the old PulseAudio layout
// ("FluidSynth" audio + "FLUID Synth (pid)" MIDI).
const NAME_SYNTH: &str = "Synth";
const SYNTH_SOUNDFONT: &str = "/usr/share/soundfonts/FluidR3_GM.sf2";

// ────────────────────────────────────────────────────────────────────
// DEVICES & LANES — the machine's wiring vocabulary.
// ────────────────────────────────────────────────────────────────────

/// A set of ports on a PipeWire node. `node` matches the node name by
/// substring; `port` additionally narrows to ports whose own name contains
/// that substring (`""` = every port).
#[derive(Debug, Clone, Copy)]
struct Device {
    node: &'static str,
    port: &'static str,
}

const fn dev(node: &'static str, port: &'static str) -> Device {
    Device { node, port }
}

// Mic input (capture_FL/FR, audio out). The only part of the physical
// interface the manager touches.
const MIC_INPUT: Device = dev(NAME_MIC, "capture_");

// The dedicated mic processor (a pw-jack client, micproc-jack): mic enters
// `in_*`, the processed stream leaves on `out_*`.
const MICPROC_INPUT: Device = dev(NAME_MICPROC, "in_");
const MICPROC_OUTPUT: Device = dev(NAME_MICPROC, "out_");

// The "vmic" virtual mic (input.vmic). Its PLAYBACK ports are the app feed —
// mic + synth land here so applications record them. Its MONITOR ports echo
// that feed and are what the monitor route taps into the default speaker.
const VMIC_SINK_IN: Device = dev(NAME_VMIC, "playback_");
const VMIC_MONITOR: Device = dev(NAME_VMIC, "monitor_");

// The MIDI keyboard's capture port (MIDI out of the keys). PipeWire
// aggregates every ALSA seq device under one node ("Midi-Bridge"), so match
// by PORT NAME (the keyboard's ports are named "Oxygen 49 (capture)"), not
// by node.
const KEYBOARD_OUT: Device = dev("", "Oxygen");

// The software synth: one JACK node carrying MIDI-in + audio-out.
const SYNTH_ANY: Device = dev(NAME_SYNTH, "");

// ────────────────────────────────────────────────────────────────────
// ROUTING TABLE — edit these lines to rewire the machine.
// ────────────────────────────────────────────────────────────────────

/// A declarative wiring rule. Matching is done on the live graph each poll.
enum Route {
    /// Audio-out ports of `src`, keyed by their channel suffix
    /// (`FL`, `FR`, `1`, ...), point at named audio-in ports of `dst`.
    /// Additive (`exclusive: false`): nothing extra is torn down.
    /// Exclusive (`exclusive: true`): anything `src` has into `dst` that
    /// `map` doesn't declare is pulled.
    Channels {
        src: Device,
        dst: Device,
        map: &'static [(&'static str, &'static str)],
        exclusive: bool,
    },
}

/// Plain channel-by-channel map, additive.
fn pairs(src: Device, dst: Device, map: &'static [(&'static str, &'static str)]) -> Route {
    Route::Channels { src, dst, map, exclusive: false }
}

/// Channel-by-channel map where `src` owns `dst`'s ports: anything not in
/// `map` gets disconnected each poll.
fn pairs_exclusive(src: Device, dst: Device, map: &'static [(&'static str, &'static str)]) -> Route {
    Route::Channels { src, dst, map, exclusive: true }
}

/// THE ROUTING TABLE. Rewire the machine here.
fn routes() -> Vec<Route> {
    vec![
        // Raw mic -> the mic processor. Very standard left-to-left /
        // right-to-right wiring: capture_FL -> in_L, capture_FR -> in_R.
        // The micproc processor itself does the mono->stereo conversion, so
        // no fanning is needed here. Exclusive: nothing else may drive the
        // processor's inputs.
        pairs_exclusive(MIC_INPUT, MICPROC_INPUT, &[("FL", "in_L"), ("FR", "in_R")]),

        // Processed mic -> the vmic app feed (recorded by apps), also
        // standard left-to-left / right-to-right. Additive so other sources
        // could share the feed; the whole lane is what the monitor route taps
        // into the speakers.
        pairs(
            MICPROC_OUTPUT,
            VMIC_SINK_IN,
            &[("L", "playback_FL"), ("R", "playback_FR")],
        ),
    ]
}

// ────────────────────────────────────────────────────────────────────
// PORT MODEL
// ────────────────────────────────────────────────────────────────────

/// A PipeWire port, referenced by its `device:name` alias.
#[derive(Debug, Clone, Hash, PartialEq, Eq)]
struct Port {
    device: String,
    name: String,
}

/// Extra facts about a port, gathered while enumerating.
#[derive(Debug, Clone)]
struct PortInfo {
    format: String,   // e.g. "32 bit float mono audio", "8 bit raw midi"
    direction: String, // "in" | "out"
}

impl PortInfo {
    fn kind(&self) -> PortKind {
        let is_midi = self.format.contains("midi");
        let out = self.direction == "out";
        match (is_midi, out) {
            (true, true) => PortKind::MidiOut,
            (true, false) => PortKind::MidiIn,
            (false, true) => PortKind::AudioOut,
            (false, false) => PortKind::AudioIn,
        }
    }
}

impl Port {
    fn from_alias(alias: &str) -> Option<Port> {
        let (device, name) = alias.trim().split_once(':')?;
        if device.is_empty() || name.is_empty() {
            return None;
        }
        Some(Port {
            device: device.to_string(),
            name: name.to_string(),
        })
    }

    fn to_alias(&self) -> String {
        format!("{}:{}", self.device, self.name)
    }

    /// The part after the last `_` in the port name, e.g. `FL` from
    /// `capture_FL`, `1` from `monitor_1`. Used as a routing key.
    fn channel(&self) -> Option<&str> {
        self.name.rsplit_once('_').map(|(_, ch)| ch)
    }
}

type Link = (Port, Port);

/// Which stream kind a port carries.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum PortKind {
    AudioOut,
    AudioIn,
    MidiOut,
    MidiIn,
}

// ────────────────────────────────────────────────────────────────────
// MANAGER
// ────────────────────────────────────────────────────────────────────

struct PipeWireManager {
    ports: Vec<(Port, PortInfo)>,
    links: HashSet<Link>,
    synth: Option<Child>,
    synth_stdin: Option<ChildStdin>,
}

impl PipeWireManager {
    fn new() -> Self {
        PipeWireManager {
            ports: Vec::new(),
            links: HashSet::new(),
            synth: None,
            synth_stdin: None,
        }
    }

    // ── enumeration ────────────────────────────────────────────────

    fn refresh(&mut self) {
        self.ports = Self::enumerate_ports();
        self.links = Self::existing_links();
    }

    /// Read every Node and Port object from a SINGLE unfiltered `pw-cli
    /// list-objects` call (instead of two separate `list-objects Node` /
    /// `list-objects Port` subprocess spawns every poll) and parse both in
    /// two passes over the same text. Safe because `node.name` only ever
    /// appears on Node blocks and `node.id`/`port.name`/`port.alias`/
    /// `format.dsp`/`port.direction` only ever appear on Port blocks on this
    /// PipeWire version (verified against the live graph before making this
    /// change) — each pass's `else if` chain simply ignores lines from
    /// every other interleaved object type (Client, Link, Device, ...).
    ///
    /// Stored as a `Vec`, not a map, because MIDI devices expose both a
    /// capture and a playback port under the *same* alias (a map keyed by
    /// alias would silently drop one direction).
    ///
    /// Ports are keyed by the canonical `node.name:port.name` pair — the same
    /// vocabulary `pw-link` uses to connect and to list the graph. Neither
    /// `port.alias` (built from the node *description*; e.g. filter-chain
    /// nodes alias as `vmic:` while their node is `input.vmic`)
    /// nor `object.path` (adapter-generated like `micproc:input_0`) agrees
    /// with `pw-link`, so the join uses `node.id -> node.name`.
    fn enumerate_ports() -> Vec<(Port, PortInfo)> {
        let dump = run_cmd(&["pw-cli", "list-objects"]);

        // Pass 1: node.id -> node.name, from Node blocks.
        let mut node_names: std::collections::HashMap<String, String> = Default::default();
        let mut block_id: Option<String> = None;
        for line in dump.lines() {
            let t = line.trim();
            if t.starts_with("id ") && t.contains("type PipeWire:Interface:Node") {
                if let Some(rest) = t.strip_prefix("id ") {
                    if let Some(name) = rest.split(',').next() {
                        block_id = Some(name.trim().to_string());
                    }
                }
            } else if let Some(v) = quoted_value(t, "node.name") {
                if let Some(id) = &block_id {
                    node_names.insert(id.clone(), v);
                }
            }
        }

        // Pass 2: Port blocks, resolving each port's owning node via
        // node_names from pass 1.
        let mut ports = Vec::new();
        let mut node: Option<String> = None;
        let mut pname: Option<String> = None;
        let mut alias: Option<String> = None;
        let mut format: Option<String> = None;
        let mut direction: Option<String> = None;

        for line in dump.lines() {
            let t = line.trim();
            if t.starts_with("id ") && t.contains("type PipeWire:Interface:Port") {
                commit_port(
                    &mut ports,
                    node.as_ref(),
                    pname.as_ref(),
                    alias.as_ref(),
                    format.as_ref(),
                    direction.as_ref(),
                );
                node = None;
                pname = None;
                alias = None;
                format = None;
                direction = None;
            } else if let Some(v) = quoted_value(t, "node.id") {
                // Owning node (ports have no `node.name` of their own).
                if let Some(n) = node_names.get(&v) {
                    node = Some(n.clone());
                }
            } else if let Some(v) = quoted_value(t, "port.name") {
                pname = Some(v);
            } else if let Some(v) = quoted_value(t, "port.alias") {
                alias = Some(v);
            } else if let Some(v) = quoted_value(t, "format.dsp") {
                format = Some(v);
            } else if let Some(v) = quoted_value(t, "port.direction") {
                direction = Some(v);
            }
        }
        commit_port(
            &mut ports,
            node.as_ref(),
            pname.as_ref(),
            alias.as_ref(),
            format.as_ref(),
            direction.as_ref(),
        );

        ports
    }

    /// Read the current link graph from `pw-link -l`.
    fn existing_links() -> HashSet<Link> {
        let out = run_cmd(&["pw-link", "-l"]);
        let mut links = HashSet::new();
        let mut current: Option<Port> = None;

        for line in out.lines() {
            let t = line.trim();
            if t.starts_with("|->") {
                if let (Some(src), Some(dst)) = (current.clone(), Port::from_alias(&t[3..])) {
                    links.insert((src, dst));
                }
            } else if t.starts_with("|<-") {
                if let (Some(src), Some(dst)) = (Port::from_alias(&t[3..]), current.clone()) {
                    links.insert((src, dst));
                }
            } else if !t.is_empty() {
                current = Port::from_alias(t);
            }
        }

        links
    }

    // ── port queries ───────────────────────────────────────────────

    /// All ports matching a device pattern and stream kind. Matching is
    /// case-insensitive so node names like `fluidsynth`, `FluidSynth` and
    /// `FLUID Synth (pid)` all match the same device pattern.
    fn ports(&self, d: &Device, kind: PortKind) -> Vec<Port> {
        let node_q = d.node.to_lowercase();
        let port_q = d.port.to_lowercase();
        self.ports
            .iter()
            .filter(|(p, info)| {
                p.device.to_lowercase().contains(&node_q)
                    && p.name.to_lowercase().contains(&port_q)
                    && info.kind() == kind
            })
            .map(|(p, _)| p.clone())
            .collect()
    }

    /// Audio-in playback ports of a single named sink node (the dynamic
    /// default speaker, resolved per poll from `pactl`).
    fn sink_inputs(&self, sink_name: &str) -> Vec<Port> {
        self.ports
            .iter()
            .filter(|(p, info)| {
                p.device == sink_name && p.name.starts_with("playback_") && info.kind() == PortKind::AudioIn
            })
            .map(|(p, _)| p.clone())
            .collect()
    }

    // ── link management ────────────────────────────────────────────

    /// Create `source -> sink` if it does not already exist, retrying while
    /// ports may still be coming up.
    fn connect(&mut self, source: &Port, sink: &Port) -> bool {
        let source_alias = source.to_alias();
        let sink_alias = sink.to_alias();

        if self.links.contains(&(source.clone(), sink.clone())) {
            println!("Link already exists: {} -> {}", source_alias, sink_alias);
            return true;
        }

        for attempt in 1..=LINK_ATTEMPTS {
            let output = Command::new("pw-link")
                .args(&[&source_alias, &sink_alias])
                .output();

            match output {
                Ok(result) if result.status.success() => {
                    self.links.insert((source.clone(), sink.clone()));
                    println!("Created link: {} -> {}", source_alias, sink_alias);
                    return true;
                }
                Ok(result) => {
                    let stderr = String::from_utf8_lossy(&result.stderr);
                    if stderr.contains("File exists") {
                        self.links.insert((source.clone(), sink.clone()));
                        println!("Link already exists: {} -> {}", source_alias, sink_alias);
                        return true;
                    }
                    if stderr.contains("No such file or directory") {
                        eprintln!(
                            "Ports not ready: {} -> {} (attempt {})",
                            source_alias, sink_alias, attempt
                        );
                    } else {
                        eprintln!(
                            "Failed to create link: {} -> {} (attempt {}): {}",
                            source_alias, sink_alias, attempt, stderr.trim()
                        );
                    }
                }
                Err(e) => {
                    eprintln!(
                        "Error running pw-link: {} -> {} (attempt {}): {}",
                        source_alias, sink_alias, attempt, e
                    );
                }
            }

            if attempt < LINK_ATTEMPTS {
                thread::sleep(LINK_RETRY_DELAY);
            }
        }

        false
    }

    /// Remove `source -> sink`, if present. `pw-link -d` is a harmless no-op
    /// when the pair isn't actually linked, so this tolerates stale targets.
    fn disconnect(&mut self, source: &Port, sink: &Port) {
        let source_alias = source.to_alias();
        let sink_alias = sink.to_alias();
        let _ = Command::new("pw-link")
            .args(&["--disconnect", &source_alias, &sink_alias])
            .output();
        self.links.remove(&(source.clone(), sink.clone()));
        println!("Removed link: {} -> {}", source_alias, sink_alias);
    }

    // ── synth lifecycle (on-demand) ────────────────────────────────

    fn synth_running(&mut self) -> bool {
        self.synth_stdin.is_some() && self.synth.as_mut().is_some_and(|c| is_alive(c))
    }

    fn ensure_synth_running(&mut self) {
        if self.synth_running() {
            return;
        }

        // Careful: if the previous child died while we still hold our handle,
        // reap it and restart.
        if let Some(mut child) = self.synth.take() {
            if child.try_wait().ok().flatten().is_none() {
                eprintln!("{} died unexpectedly; restarting", NAME_SYNTH);
            }
            self.synth_stdin.take();
            let _ = child.kill();
            let _ = child.wait();
        }

        // Caveat: fluidsynth's interactive shell panics on stdin EOF. As a
        // service our stdin is /dev/null, so we pipe it and hold the write end
        // open (`synth_stdin`) to keep it alive.
        //
        // JACK driver (`-a jack -o midi.driver=jack`) so the synth appears in
        // qpwgraph as ONE node ("fluidsynth-midi") with a MIDI-in port and two
        // audio-out ports — the visible MIDI->audio conversion box. `-r 48000`
        // matches the PipeWire JACK sample rate. (No `-i`: fluidsynth exits
        // when stdin isn't a live shell.)
        let mut child = match Command::new("fluidsynth")
            .args(["-a", "jack", "-r", "48000", "-c", "2", "-g", "1.0"])
            .args(["-o", "midi.driver=jack", SYNTH_SOUNDFONT])
            .stdin(Stdio::piped())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn()
        {
            Ok(c) => c,
            Err(e) => {
                eprintln!("Failed to start {}: {}", NAME_SYNTH, e);
                return;
            }
        };

        self.synth_stdin = child.stdin.take();
        self.synth = Some(child);
        println!("Started {}", NAME_SYNTH);
    }

    fn stop_synth(&mut self) {
        self.synth_stdin.take();
        if let Some(mut child) = self.synth.take() {
            let _ = child.kill();
            let _ = child.wait();
            println!("Stopped {}", NAME_SYNTH);
        }
    }

    // ── route engine ───────────────────────────────────────────────

    /// Apply the routing table, then the on-demand synth lifecycle.
    fn apply_routes(&mut self) {
        self.ensure_vmic();
        for route in routes() {
            self.apply_route(route);
        }
        self.apply_vmic_monitor_route();
        self.apply_synth_route();
        self.unroute_stray_mix_links();
    }

    /// Tap the vmic sink's MONITOR (the whole app feed: processed mic +
    /// synth) into whatever sink is currently the default speaker, so your
    /// voice is heard mixed with app audio. Guards:
    ///   - if the default speaker device IS the vmic itself, do nothing and
    ///     leave the vmic's connections exactly as they are.
    ///   - vmic monitor ports may only feed the current default speaker;
    ///     anything else they're linked into (a stale default, a howlback
    ///     into micproc's inputs) is pulled.
    fn apply_vmic_monitor_route(&mut self) {
        let Some(default) = default_sink() else {
            return;
        };
        if default.contains(NAME_VMIC) {
            println!("Default speaker is the vmic itself; leaving its connections alone");
            return;
        }

        let sinks = self.sink_inputs(&default);
        if sinks.is_empty() {
            return;
        }

        // Channel-for-channel: monitor_FL -> <default>:playback_FL, etc.
        for monitor in self.ports(&VMIC_MONITOR, PortKind::AudioOut) {
            let Some(ch) = monitor.channel() else { continue };
            let want = format!("playback_{ch}");
            if let Some(sink) = sinks.iter().find(|s| s.name == want) {
                self.connect(&monitor, sink);
            }
        }

        let stray: Vec<Link> = self
            .links
            .iter()
            .filter(|(src, sink)| {
                src.device.contains(NAME_VMIC)
                    && src.name.starts_with("monitor_")
                    && !(sink.device == default && sink.name.starts_with("playback_"))
            })
            .cloned()
            .collect();
        for (src, sink) in stray {
            self.disconnect(&src, &sink);
        }
    }

    /// Make sure the virtual mic exists for applications to record. The vmic
    /// filter-chain (pipewire.conf.d/99-vmic.conf) provides a dedicated
    /// Audio/Source; as a fallback we can provision a Pulse null-sink (single
    /// node, monitor-only source) so apps always have something to pick.
    fn ensure_vmic(&mut self) {
        // `self.ports` was already refreshed this poll from `pw-cli
        // list-objects` (see `refresh()`, called just before `apply_routes`)
        // and already contains vmic's ports if the filter-chain node exists
        // -- checking it here (same substring test the rest of this file
        // already uses for vmic, e.g. `apply_vmic_monitor_route`) avoids a
        // redundant `pactl list short sinks` subprocess spawn every poll.
        let has_vmic = self.ports.iter().any(|(p, _)| p.device.contains(NAME_VMIC));
        if has_vmic {
            return;
        }
        let out = run_cmd(&[
            "pactl",
            "load-module",
            "module-null-sink",
            &format!("sink_name={}", NAME_VMIC),
        ]);
        println!("Loaded vmic null-sink: {}", out.trim());
    }

    fn apply_route(&mut self, route: Route) {
        match route {
            Route::Channels { src, dst, map, exclusive } => {
                self.route_channels(src, dst, map, exclusive);
            }
        }
    }

    /// Channel-keyed routing. Both `pairs` and `pairs_exclusive` land here.
    fn route_channels(
        &mut self,
        src: Device,
        dst: Device,
        map: &[(&str, &str)],
        exclusive: bool,
    ) {
        let sources = self.ports(&src, PortKind::AudioOut);
        let sinks = self.ports(&dst, PortKind::AudioIn);

        for source in &sources {
            let Some(ch) = source.channel() else { continue };
            let intended: Vec<&str> = map
                .iter()
                .filter(|(key, _)| key == &ch)
                .map(|(_, name)| *name)
                .collect();
            if intended.is_empty() {
                continue;
            }

            for sink_name in intended.clone() {
                if let Some(sink) = sinks.iter().find(|s| &s.name == sink_name) {
                    self.connect(source, sink);
                }
            }

            // Ownership: this route claims every link `source` has into
            // `dst`; anything not declared in `map` gets pulled.
            if exclusive {
                for leak in &sinks {
                    if !intended.contains(&leak.name.as_str()) {
                        self.disconnect(source, leak);
                    }
                }
            }
        }
    }

    /// Anything on the micproc or the vmic nodes that isn't the routing table
    /// above is stray, so links stay exact even when apps auto-connect:
    ///   - micproc's inputs belong to the mic alone.
    ///   - micproc's outputs may reach only the vmic app feed (monitoring is
    ///     the vmic-monitor route's job).
    fn unroute_stray_mix_links(&mut self) {
        let stray: Vec<Link> = self
            .links
            .iter()
            .filter(|(src, sink)| {
                let micproc_out = src.device.contains(NAME_MICPROC) && src.name.starts_with("out_");
                let to_vmic =
                    sink.device.contains(NAME_VMIC) && sink.name.starts_with("playback_");

                // micproc inputs: only the mic, on the standard diagonal
                // (capture_FL -> in_L, capture_FR -> in_R), may drive them.
                let mic_to_proc = src.device.contains(NAME_MIC)
                    && sink.device.contains(NAME_MICPROC)
                    && ((src.name == "capture_FL" && sink.name == "in_L")
                        || (src.name == "capture_FR" && sink.name == "in_R"));
                let bad_micproc_in = sink.device.contains(NAME_MICPROC)
                    && sink.name.starts_with("in_")
                    && !mic_to_proc;

                // micproc outputs: only the vmic app feed.
                let bad_micproc_out = micproc_out && !to_vmic;

                bad_micproc_in || bad_micproc_out
            })
            .cloned()
            .collect();

        for (src, sink) in stray {
            self.disconnect(&src, &sink);
        }
    }

    /// Oxygen 49 MIDI -> fluidsynth -> the vmic app feed. The synth runs only
    /// while the keyboard is plugged in.
    fn apply_synth_route(&mut self) {
        let keyboard_plugged = !self.ports(&KEYBOARD_OUT, PortKind::MidiOut).is_empty();

        if !keyboard_plugged {
            if self.synth.is_some() {
                self.stop_synth();
            }
            return;
        }

        self.ensure_synth_running();
        if !self.synth_running() {
            return;
        }

        // MIDI: every keyboard capture port -> the synth's MIDI input.
        let synth_midi_in = self.ports(&SYNTH_ANY, PortKind::MidiIn).into_iter().next();
        if let Some(synth_in) = synth_midi_in {
            for kb in self.ports(&KEYBOARD_OUT, PortKind::MidiOut) {
                self.connect(&kb, &synth_in);
            }
        }

        // The synth feeds the app-feed vmic, exactly like the mic does. Apps
        // may record it; it stays off the monitoring path. The single JACK
        // node names its outputs `left`/`right`; the old PulseAudio layout
        // (`output_FL`/`output_FR`) is also accepted.
        let vmic_ins = self.ports(&VMIC_SINK_IN, PortKind::AudioIn);
        for port in self.ports(&SYNTH_ANY, PortKind::AudioOut) {
            let dest = match port.name.as_str() {
                "left" | "output_FL" | "FL" => "playback_FL",
                "right" | "output_FR" | "FR" => "playback_FR",
                _ => continue,
            };
            if let Some(sink) = vmic_ins.iter().find(|s| s.name == dest) {
                self.connect(&port, sink);
            }
        }

        self.unroute_stray_synth_links();
    }

    /// Any link leaving the synth that doesn't land on the vmic app feed is
    /// stray (nothing should normally do this now that the synth is a JACK
    /// client, but keep the graph exact anyway).
    fn unroute_stray_synth_links(&mut self) {
        let stray: Vec<Link> = self
            .links
            .iter()
            .filter(|(src, sink)| {
                src.device.to_lowercase().contains(&NAME_SYNTH.to_lowercase())
                    && !(sink
                        .device
                        .to_lowercase()
                        .contains(&NAME_VMIC.to_lowercase())
                        && sink.name.starts_with("playback_"))
            })
            .cloned()
            .collect();

        for (src, sink) in stray {
            self.disconnect(&src, &sink);
        }
    }

    // ── main loop ──────────────────────────────────────────────────

    fn run(&mut self) {
        println!("PipeWire Links Manager starting...");

        thread::sleep(STARTUP_DELAY);

        loop {
            self.refresh();
            println!("Running connection setup...");
            self.apply_routes();
            println!(
                "Connection setup complete ({} ports, {} links)",
                self.ports.len(),
                self.links.len()
            );
            thread::sleep(POLL_INTERVAL);
        }
    }
}

// ────────────────────────────────────────────────────────────────────
// HELPERS
// ────────────────────────────────────────────────────────────────────

fn run_cmd(args: &[&str]) -> String {
    let output = Command::new(args[0])
        .args(&args[1..])
        .output()
        .unwrap_or_else(|_| {
            eprintln!("Failed to run {}", args.join(" "));
            std::process::exit(1);
        });
    String::from_utf8_lossy(&output.stdout).into_owned()
}

/// Name of the currently-default speaker sink (the `node.name` vocabulary
/// `pw-link` uses), or `None` if there isn't one worth wiring.
fn default_sink() -> Option<String> {
    let out = run_cmd(&["pactl", "get-default-sink"]);
    let name = out.trim();
    if name.is_empty() || name == "auto_null" {
        None
    } else {
        Some(name.to_string())
    }
}

fn is_alive(child: &mut Child) -> bool {
    child.try_wait().ok().flatten().is_none()
}

/// Pull the quoted value of `key = "value"` from a `pw-cli` line.
fn quoted_value(line: &str, key: &str) -> Option<String> {
    let rest = line.strip_prefix(key)?.strip_prefix(" = ")?;
    let value = rest.trim().trim_matches('"');
    if value.is_empty() {
        None
    } else {
        Some(value.to_string())
    }
}

#[allow(clippy::too_many_arguments)]
fn commit_port(
    ports: &mut Vec<(Port, PortInfo)>,
    node: Option<&String>,
    pname: Option<&String>,
    alias: Option<&String>,
    format: Option<&String>,
    direction: Option<&String>,
) {
    if let (Some(format), Some(direction)) = (format, direction) {
        // Canonical `node.name:port.name` (matches `pw-link`'s vocabulary).
        // Fall back to `port.alias` when the owning node is unknown. Do NOT
        // trust `object.path` or adapter names.
        let key = match (node, pname) {
            (Some(n), Some(p)) if !n.is_empty() && !p.is_empty() => format!("{}:{}", n, p),
            _ => match alias {
                Some(a) => a.clone(),
                None => String::new(),
            },
        };
        if let Some(port) = Port::from_alias(&key) {
            ports.push((
                port,
                PortInfo {
                    format: format.clone(),
                    direction: direction.clone(),
                },
            ));
        }
    }
}

fn main() {
    let mut manager = PipeWireManager::new();
    manager.run();
}
