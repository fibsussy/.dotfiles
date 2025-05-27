#!/bin/bash

ip=$(ip -4 addr show up | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+' | grep -v '127.0.0.1' | head -n 1)
if [ -n "$ip" ]; then
    echo "$ip"
else
    echo "No con"
fi
