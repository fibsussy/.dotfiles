#!/usr/bin/env bash

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
wait_for_port alsa_input.usb-Native_Instruments_Komplete_Audio_1_0000607B-00.analog-stereo:capture_FL

# Link them
link_if_missing input.loopmix:monitor_1 alsa_output.usb-Native_Instruments_Komplete_Audio_1_0000607B-00.analog-stereo:playback_FL
link_if_missing input.loopmix:monitor_2 alsa_output.usb-Native_Instruments_Komplete_Audio_1_0000607B-00.analog-stereo:playback_FR
link_if_missing alsa_input.usb-Native_Instruments_Komplete_Audio_1_0000607B-00.analog-stereo:capture_FL input.loopmix:playback_3
link_if_missing alsa_input.usb-Native_Instruments_Komplete_Audio_1_0000607B-00.analog-stereo:capture_FL input.loopmix:playback_4

exit 0
