#!/bin/bash

if ! hyprctl clients -j | jq -e '.[] | select(.workspace.id == '"$(hyprctl activeworkspace -j | jq '.id')"')' > /dev/null; then
    $1 &
fi
