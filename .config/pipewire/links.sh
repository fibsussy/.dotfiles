#!/usr/bin/env bash

# Find first device with Komplete in the name
find_komplete_device() {
    local type=$1
    pw-cli list-objects Node | grep "Komplete" | grep "$type" | head -1 | sed 's/.*node.name = "\([^"]*\)".*/\1/'
}

KOMPLETE_INPUT=$(find_komplete_device "alsa_input")
KOMPLETE_OUTPUT=$(find_komplete_device "alsa_output")

wait_for_port() {
    local port=$1
    for i in {1..20}; do
        if pw-cli list-objects Port | grep -q "$port"; then
            return 0
        fi
        sleep 0.1
    done
    return 1
}

link_if_missing() {
    local src=$1 dst=$2
    if ! pw-link -l | grep -q "${src} -> ${dst}"; then
        pw-link "$src" "$dst" >/dev/null 2>&1 || true
    fi
}

# Wait for all ports
wait_for_port input.loopmix:monitor_1
wait_for_port input.loopmix:monitor_2
wait_for_port input.loopmix:playback_3
wait_for_port input.loopmix:playback_4
wait_for_port "${KOMPLETE_INPUT}:capture_FL"

# Link them
link_if_missing input.loopmix:monitor_1 "${KOMPLETE_OUTPUT}:playback_FL"
link_if_missing input.loopmix:monitor_2 "${KOMPLETE_OUTPUT}:playback_FR"
link_if_missing "${KOMPLETE_INPUT}:capture_FL" input.loopmix:playback_3
link_if_missing "${KOMPLETE_INPUT}:capture_FL" input.loopmix:playback_4

exit 0
