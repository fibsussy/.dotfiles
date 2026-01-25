#!/bin/bash

# Get session info for navigation
# Usage: ./session_info.sh current|total|next|prev

get_current_session_index() {
    local attached=$(tmux display -p "#{session_name}")
    local index=0
    while IFS= read -r line; do
        local session_name=$(echo "$line" | awk '{print $2}')
        if [ "$session_name" = "$attached" ]; then
            echo $index
            return
        fi
        ((index++))
    done < <(tmux list-sessions -F "#{session_created} #{session_name} #{session_windows}" | sort -n)
}

get_session_name() {
    local target_index=$1
    local index=0
    while IFS= read -r line; do
        if [ "$index" -eq "$target_index" ]; then
            echo "$line" | awk '{print $2}'
            return
        fi
        ((index++))
    done < <(tmux list-sessions -F "#{session_created} #{session_name} #{session_windows}" | sort -n)
}

get_total_sessions() {
    tmux list-sessions | wc -l
}

case "$1" in
    "list"|"info")
        index=0
        attached_session=$(tmux display -p "#{session_name}")
        while IFS= read -r line; do
            session_name=$(echo "$line" | awk '{print $2}')
            window_count=$(echo "$line" | awk '{print $3}')
            if [ "$session_name" = "$attached_session" ]; then
                printf "(%d) + %s: %s windows (attached)\n" "$index" "$session_name" "$window_count"
            else
                printf "(%d) + %s: %s windows\n" "$index" "$session_name" "$window_count"
            fi
            ((index++))
        done < <(tmux list-sessions -F "#{session_created} #{session_name} #{session_windows}" | sort -n)
        ;;
    "current")
        get_current_session_index
        ;;
    "total")
        get_total_sessions
        ;;
    "next")
        current=$(get_current_session_index)
        total=$(get_total_sessions)
        if [ "$current" -lt "$((total - 1))" ]; then
            target_index=$((current + 1))
            session_line=$(tmux list-sessions | sed -n "$((target_index + 1))p")
            session_name=$(echo "$session_line" | cut -d: -f1)
            if [ "$session_name" = "~" ]; then
                tmux switch-client -t "\\~"
            elif [ -n "$session_name" ]; then
                tmux switch-client -t "$session_name"
            fi
        fi
        ;;
    "prev")
        current=$(get_current_session_index)
        if [ "$current" -gt 0 ]; then
            target_index=$((current - 1))
            session_name=$(get_session_name $target_index)
            if [ "$session_name" = "~" ]; then
                tmux switch-client -t "\\~"
            elif [ -n "$session_name" ]; then
                tmux switch-client -t "$session_name"
            fi
        fi
        ;;
    "down")
        current=$(get_current_session_index)
        total=$(get_total_sessions)
        if [ "$current" -lt "$((total - 1))" ]; then
            target_index=$((current + 1))
            session_name=$(get_session_name $target_index)
            if [ "$session_name" = "~" ]; then
                tmux switch-client -t "\\~"
            elif [ -n "$session_name" ]; then
                tmux switch-client -t "$session_name"
            fi
        fi
        ;;
esac