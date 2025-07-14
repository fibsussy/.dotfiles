#!/bin/bash

_fetch_cursor_position() {
  local pos
  # Disable echo and set raw mode
  oldstty=$(stty -g)
  stty raw -echo min 0 time 10
  # Send cursor position query
  printf '\033[6n' > /dev/tty
  # Read response with timeout
  IFS='[;R' read -r -d R -t 1 _ _cursor_row _cursor_col < /dev/tty
  # Restore terminal settings
  stty "$oldstty"
  # Ensure valid numeric values, default to 1 if parsing fails
  _cursor_row=${_cursor_row:-1}
  _cursor_col=${_cursor_col:-1}
  # Adjust for 1-based indexing
  ((_cursor_row++))
  ((_cursor_col++))
}

height=$(fastfetch --logo none | wc -l)
fastfetch --key-padding-left 33 --logo none
_fetch_cursor_position
y=$(($_cursor_row - $height))
if [ -n "$TMUX" ]; then
  y=$((y + 1))
fi
kitten icat --align=left --place=30x16@2x$y $(~/.config/fastfetch/fastfetch_colorer.sh)
tput cup $(($_cursor_row - 2)) 0
