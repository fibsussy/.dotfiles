#!/usr/bin/env bash
set -euo pipefail

USER=$(whoami)
UID_NUM=$(id -u "$USER")
RUNTIME_DIR="/run/user/$UID_NUM"

[[ -d "$RUNTIME_DIR" ]] || {
  echo "No runtime dir for $USER" >&2
  exit 1
}

WAYLAND_SOCKET=$(find "$RUNTIME_DIR" -maxdepth 1 -type s -name 'wayland-*' -printf '%f\n' | head -n1)

[[ -n "$WAYLAND_SOCKET" ]] || {
  echo "No Wayland session for $USER" >&2
  exit 1
}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS_FILE="$DIR/password.txt"

[[ -f "$PASS_FILE" ]] || {
  echo "Missing password.txt" >&2
  exit 1
}

export XDG_RUNTIME_DIR="$RUNTIME_DIR"
export WAYLAND_DISPLAY="$WAYLAND_SOCKET"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$RUNTIME_DIR/bus"

exec wtype -d 1 "$(cat "$PASS_FILE")"
