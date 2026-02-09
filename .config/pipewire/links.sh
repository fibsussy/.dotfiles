#!/usr/bin/env bash

LOG_FILE="/tmp/pipewire-links.log"
MONITOR_INTERVAL=5

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Find first device with Komplete in the name
find_komplete_device() {
    local type=$1
    pw-cli list-objects Node | grep "Komplete" | grep "$type" | head -1 | sed 's/.*node.name = "\([^"]*\)".*/\1/'
}

# Get all hardware outputs
get_all_hardware_outputs() {
    pw-cli list-objects Node | grep "alsa_output" | sed 's/.*node.name = "\([^"]*\)".*/\1/'
}

wait_for_port() {
    local port=$1
    for i in {1..60}; do
        if pw-link -l | grep -q "$port" || pw-cli list-objects Port | grep -q "$port"; then
            return 0
        fi
        sleep 0.1
    done
    return 1
}

link_if_missing() {
    local src=$1 dst=$2
    if ! pw-link -l | grep -q "${src} -> ${dst}"; then
        if pw-link "$src" "$dst" 2>/dev/null; then
            log "Linked $src -> $dst"
        else
            log "Failed to link $src -> $dst"
        fi
    fi
}

setup_links() {
    log "Setting up audio links..."
    
    # Get device info
    KOMPLETE_INPUT=$(find_komplete_device "alsa_input")
    ALL_OUTPUTS=$(get_all_hardware_outputs)
    
    if [ -z "$KOMPLETE_INPUT" ]; then
        log "Komplete input device not found"
        return 1
    fi
    
    log "Found Komplete input: $KOMPLETE_INPUT"
    log "Found outputs: $ALL_OUTPUTS"
    
    # Wait for all ports
    log "Waiting for ports..."
    wait_for_port input.loopmix:monitor_1 || { log "Timeout waiting for input.loopmix:monitor_1"; return 1; }
    wait_for_port input.loopmix:monitor_2 || { log "Timeout waiting for input.loopmix:monitor_2"; return 1; }
    wait_for_port input.loopmix:playback_2 || { log "Timeout waiting for input.loopmix:playback_2"; return 1; }
    wait_for_port input.loopmix:playback_3 || { log "Timeout waiting for input.loopmix:playback_3"; return 1; }
    wait_for_port repeater:monitor_FL || { log "Timeout waiting for repeater:monitor_FL"; return 1; }
    wait_for_port repeater:monitor_FR || { log "Timeout waiting for repeater:monitor_FR"; return 1; }
    wait_for_port repeater:playback_FL || { log "Timeout waiting for repeater:playback_FL"; return 1; }
    wait_for_port repeater:playback_FR || { log "Timeout waiting for repeater:playback_FR"; return 1; }
    wait_for_port "Komplete Audio 1:capture_FL" || { log "Timeout waiting for Komplete Audio 1:capture_FL"; return 1; }
    wait_for_port "Komplete Audio 1:capture_FR" || { log "Timeout waiting for Komplete Audio 1:capture_FR"; return 1; }
    
    log "All ports ready, creating links..."
    
    # Link Komplete mic (both L and R) -> loopmix playback 2 & 3 (which are channels 3 & 4)
    link_if_missing "Komplete Audio 1:capture_FL" input.loopmix:playback_3
    link_if_missing "Komplete Audio 1:capture_FR" input.loopmix:playback_3
    link_if_missing "Komplete Audio 1:capture_FL" input.loopmix:playback_4
    link_if_missing "Komplete Audio 1:capture_FR" input.loopmix:playback_4
    
    # Link loopmix monitor 1 & 2 -> repeater playback FL/FR
    link_if_missing input.loopmix:monitor_1 "repeater:playback_FL"
    link_if_missing input.loopmix:monitor_2 "repeater:playback_FR"
    
    # Link repeater monitor FL/FR -> all speakers
    for output in $ALL_OUTPUTS; do
        link_if_missing "repeater:monitor_FL" "${output}:playback_FL"
        link_if_missing "repeater:monitor_FR" "${output}:playback_FR"
    done
    
    log "Audio links setup complete"
    return 0
}

count_audio_devices() {
    pw-cli list-objects Node | grep -c "alsa_output"
}

monitor_and_restart() {
    local last_device_count=$(count_audio_devices)
    log "Starting monitoring loop with initial device count: $last_device_count"
    
    while true; do
        sleep $MONITOR_INTERVAL
        
        local current_count=$(count_audio_devices)
        if [ $current_count -ne $last_device_count ]; then
            log "Audio device count changed: $last_device_count -> $current_count"
            log "Restarting audio links..."
            setup_links
            last_device_count=$current_count
        fi
    done
}

# Main execution
log "Starting PipeWire links service..."

# Wait for PipeWire to be fully ready
sleep 5

# Initial setup
if setup_links; then
    log "Initial links setup successful"
else
    log "Initial links setup failed, will retry in monitoring loop"
fi

# Start monitoring loop
monitor_and_restart
