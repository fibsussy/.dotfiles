#!/bin/bash
# niri-window-movements.sh
# Focus / move windows across monitors using physical left-to-right,
# bottom-to-top ordering (shared with niri-focus-monitor).

set -euo pipefail

# Physical monitor positions (left-to-right, bottom-to-top for ties), one "num name" per line.
monitors() {
  niri msg -j outputs | jq -r '
    to_entries
    | map({name: .key, x: .value.logical.x, y: .value.logical.y})
    | sort_by(.x, (-.y))
    | to_entries
    | map("\(.key + 1) \(.value.name)")
    | .[]
  '
}

# Map physical monitor position to its name.
monitor_by_num() {
  monitors | awk -v n="$1" '$1 == n { print $2; found=1; exit }
      END { if (!found) exit 1 }'
}

cmd="${1:-}"
num="${2:-}"

num_monitors=$(monitors | wc -l)

case "$cmd" in
  focus-monitor)
    mon=$(monitor_by_num "$num") || { echo "Unknown monitor number: $num" >&2; exit 1; }
    exec niri msg action focus-monitor "$mon"
    ;;
  focus-monitor-column)
    # Key n maps to (monitor, column): monitors cycle 1..N, columns advance every N keys.
    n=$(printf '%d' "$num")
    mon_num=$(( ((n - 1) % num_monitors) + 1 ))
    col=$(( ((n - 1) / num_monitors) + 1 ))
    mon=$(monitor_by_num "$mon_num") || { echo "Unknown monitor number: $mon_num" >&2; exit 1; }
    niri msg action focus-monitor "$mon"
    exec niri msg action focus-column "$col"
    ;;
  move-window-to-monitor)
    mon=$(monitor_by_num "$num") || { echo "Unknown monitor number: $num" >&2; exit 1; }
    exec niri msg action move-window-to-monitor "$mon"
    ;;
  move-window-to-monitor-column)
    n=$(printf '%d' "$num")
    mon_num=$(( ((n - 1) % num_monitors) + 1 ))
    mon=$(monitor_by_num "$mon_num") || { echo "Unknown monitor number: $mon_num" >&2; exit 1; }
    exec niri msg action move-column-to-monitor "$mon"
    ;;
  *)
    cat <<'EOF' >&2
Usage: niri-window-movements.sh <command> <number>

Commands:
  focus-monitor <n>          Focus the monitor at physical position n
  focus-monitor-column <n>   Focus monitor/column by combined key index
                             (monitors cycle 1..N, columns advance every N keys)
  move-window-to-monitor <n> Move the focused window to monitor n
  move-window-to-monitor-column <n>
                             Move the focused column to the monitor of combined key index n
EOF
    exit 1
    ;;
esac
