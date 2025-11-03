#!/usr/bin/env bash
# toggle_noshare.sh

ACTION="$1"

toggle_current() {
  if hyprctl activewindow -j | jq -e 'any(.tags[]?; . == "noshare")' >/dev/null; then
    hyprctl dispatch tagwindow -- -noshare
    hyprctl dispatch setprop active noscreenshare 0
    canberra-gtk-play -i message-new-instant
  else
    hyprctl dispatch tagwindow +noshare
    hyprctl dispatch setprop active noscreenshare 1
    canberra-gtk-play -i dialog-warning
  fi
}

toggle_all() {
  json=$(hyprctl clients -j)

  # all windows already tagged?
  if echo "$json" | jq -e 'length>0 and all(.[]; ((.tags // []) | index("noshare")))' >/dev/null; then
    # remove tag + turn off prop (except shouldbenoshare*)
    echo "$json" | jq -r '.[] | select(((.tags // []) | index("shouldbenoshare*"))|not) | .address' |
      xargs -r -I{} sh -c '
        hyprctl dispatch tagwindow -- -noshare address:{};
        hyprctl dispatch setprop address:{} noscreenshare 0
      '
    canberra-gtk-play -i message-new-instant
  else
    # add tag + turn on prop
    echo "$json" | jq -r '.[].address' |
      xargs -r -I{} sh -c '
        hyprctl dispatch tagwindow +noshare address:{};
        hyprctl dispatch setprop address:{} noscreenshare 1
      '
    canberra-gtk-play -i dialog-warning
  fi
}

case "$ACTION" in
  current) toggle_current ;;
  all)     toggle_all ;;
  *)
    echo "Usage: $0 {current|all}"
    exit 1
    ;;
esac
