#!/bin/bash

# Smart navigation script for tmux
# Usage: ./smart_nav.sh left|right|up|down

DIRECTION="$1"
cur_win=$(tmux display -p "#{window_index}")
last_win=$(tmux display -p "#{session_windows}")

if [ "$DIRECTION" = "left" ]; then
    at_edge=$(tmux display -p "#{pane_at_left}")
    if [ "$at_edge" = "1" ] && [ "$cur_win" -gt 1 ]; then
        tmux previous-window
    elif [ "$at_edge" = "0" ]; then
        tmux select-pane -L
    fi
elif [ "$DIRECTION" = "right" ]; then
    at_edge=$(tmux display -p "#{pane_at_right}")
    if [ "$at_edge" = "1" ] && [ "$cur_win" -lt "$last_win" ]; then
        tmux next-window
    elif [ "$at_edge" = "0" ]; then
        tmux select-pane -R
    fi
elif [ "$DIRECTION" = "up" ]; then
    at_edge=$(tmux display -p "#{pane_at_top}")
    if [ "$at_edge" = "1" ]; then
        ~/.config/tmux/session_info.sh prev
    elif [ "$at_edge" = "0" ]; then
        tmux select-pane -U
    fi
elif [ "$DIRECTION" = "down" ]; then
    at_edge=$(tmux display -p "#{pane_at_bottom}")
    if [ "$at_edge" = "1" ]; then
        ~/.config/tmux/session_info.sh down
    elif [ "$at_edge" = "0" ]; then
        tmux select-pane -D
    fi
fi

exit 0