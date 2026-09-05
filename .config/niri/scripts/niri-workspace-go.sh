#!/bin/bash
# niri-workspace-go.sh
# Usage:
#   niri-workspace-go.sh focus <workspace-name>   → focus workspace, land on column 1
#   niri-workspace-go.sh move  <workspace-name>   → move focused column to workspace, at column 1

set -euo pipefail

cmd="${1:-}"
ws="${2:-}"

case "$cmd" in
  focus)
    niri msg action focus-workspace "$ws"
    niri msg action focus-column 1
    ;;
  move)
    niri msg action move-column-to-workspace "$ws"
    niri msg action move-column-to-index 1
    ;;
  *)
    echo "usage: niri-workspace-go.sh <focus|move> <workspace-name>" >&2
    exit 1
    ;;
esac