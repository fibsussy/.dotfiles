#!/usr/bin/env bash
# ~/.local/bin/hypr-pull-player
# deps: playerctl, jq, hyprctl
set -euo pipefail

cmd="${1:-movetomaster}"

# ----------------------------
# Player selection
# ----------------------------
pick_player() {
  # Prefer any player that is currently Playing
  if playerctl --list-all >/dev/null 2>&1; then
    while read -r p; do
      st=$(playerctl --player="$p" status 2>/dev/null || true)
      if [ "$st" = "Playing" ]; then
        echo "$p"
        return 0
      fi
    done < <(playerctl --list-all 2>/dev/null || true)
  fi
  # Fallback: playerctld's active, if running
  if playerctl --player=playerctld status >/dev/null 2>&1; then
    echo "playerctld"
    return 0
  fi
  # Fallback: first available player
  playerctl --list-all 2>/dev/null | head -n1
}

# Allow overriding player via 2nd arg, else auto-pick
player_arg="${2:-}"
player="${player_arg:-$(pick_player)}"
[ -n "${player:-}" ] || exit 0

identity=$(playerctl --player="$player" metadata --format '{{mpris:identity}}' 2>/dev/null || echo "$player")
title=$(playerctl --player="$player" metadata --format '{{xesam:title}}' 2>/dev/null || true)

# ----------------------------
# Normalize identity -> likely Hypr class
# ----------------------------
norm=$(printf '%s' "$identity" | tr '[:upper:]' '[:lower:]')
case "$norm" in
  *spotify*)   class="Spotify" ;;
  *vlc*)       class="vlc" ;;
  *mpv*)       class="mpv" ;;
  *firefox*)   class="firefox" ;;
  *chromium*)  class="Chromium" ;;
  *chrome*)    class="Google-chrome" ;;
  *brave*)     class="Brave-browser" ;;
  *)           class="" ;;
esac

# ----------------------------
# Find matching client in Hyprland
# ----------------------------
clients_json=$(hyprctl clients -j)

# find the best candidate's address + workspace id
read -r addr win_ws_id <<EOF || true
$(jq -r --arg cls "$class" --arg t "$title" '
  def ci_contains(a;b): (a|ascii_downcase) | contains(b|ascii_downcase);

  . as $all
  | (
      if ($cls != "") then
        ($all | map(select(.class == $cls)))
      else [] end
    ) as $exact
  | (
      if ($exact|length)>0 then $exact
      else
        if ($cls != "") then ($all | map(select(ci_contains(.class;$cls)))) else [] end
      end
    ) as $byclass
  | (
      if (($byclass|length)==0 and ($t!="")) then
        ($all | map(select(ci_contains(.title;$t))))
      else $byclass end
    ) as $cands
  | if ($cands|length)>0
      then ($cands[0].address + " " + (($cands[0].workspace.id|tostring)))
      else empty
    end
' <<<"$clients_json")
EOF

[ -n "${addr:-}" ] || exit 0

# Helpers
active_ws_id() { hyprctl activeworkspace -j | jq -r '.id'; }

ensure_master_layout() {
  if ! hyprctl getoption general:layout -j 2>/dev/null | jq -r '.str' | grep -q '^master$'; then
    hyprctl keyword general:layout master >/dev/null
  fi
}

movetomaster() {
  local ws
  ws="$(active_ws_id)"

  ensure_master_layout

  # Make sure it’s tiled (promotion requires tiled)
  hyprctl dispatch setfloating "address:$addr no" >/dev/null 2>&1 || true

  # Move -> Focus -> Make Master
  hyprctl dispatch movetoworkspace "$ws,address:$addr"
  hyprctl dispatch focuswindow "address:$addr"
  # Promote focused window to master (keeping focus there)
  hyprctl dispatch layoutmsg "swapwithmaster ignoremaster"
}

focusplayer() {
  # Jump to the window’s workspace (no move), then focus it
  local current_ws
  current_ws="$(active_ws_id)"
  if [ -n "${win_ws_id:-}" ] && [ "$win_ws_id" != "$current_ws" ]; then
    hyprctl dispatch workspace "$win_ws_id"
  fi
  hyprctl dispatch focuswindow "address:$addr"
}

case "$cmd" in
  movetomaster) movetomaster ;;
  focusplayer)  focusplayer ;;
esac
