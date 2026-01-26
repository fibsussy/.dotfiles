#!/bin/bash

# Get current session index (1-based) based on creation date
current=$(tmux display -p "#{session_name}")
total=$(tmux list-sessions | wc -l)

# Find current session index (1-based) sorted by creation date
index=0
while IFS= read -r line; do
    session_name=$(echo "$line" | awk '{print $2}')
    if [ "$session_name" = "$current" ]; then
        echo $((index + 1))
        exit 0
    fi
    ((index++))
done < <(tmux list-sessions -F "#{session_created} #{session_name} #{session_windows}" | sort -n)

echo "1"