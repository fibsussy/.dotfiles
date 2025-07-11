#!/bin/bash

read name transform < <(hyprctl monitors -j | jq -r '.[] | select(.focused) | "\(.name) \(.transform)"')
hyprctl keyword monitor $name, highres highrr, auto, 1, transform, $((1 - transform))
