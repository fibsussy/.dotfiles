#!/bin/bash

# Teardown existing configuration
echo "Tearing down existing virtual microphone configuration..."

# Remove old config file
rm -f ~/.config/pipewire/pipewire.conf.d/virtual-mic.conf

# Restart PipeWire to clear old loopbacks
systemctl --user restart pipewire
systemctl --user restart pipewire-pulse

# Wait for PipeWire to fully restart
sleep 2

# Create persistent virtual microphone configuration
echo "Setting up persistent virtual microphone..."

# Create PipeWire config directory if it doesn't exist
mkdir -p ~/.config/pipewire/pipewire.conf.d

# Create virtual mic config file
cp virtual-mic.conf ~/.config/pipewire/pipewire.conf.d/virtual-mic.conf

echo "Virtual microphone configuration created."
echo "Restarting PipeWire to apply changes..."

# Restart PipeWire to apply new configuration
systemctl --user restart pipewire
systemctl --user restart pipewire-pulse

# Wait for everything to settle
sleep 2

echo "Done! Select 'Virtual Microphone' as your mic in Discord/Zoom/etc."
echo "Your Komplete Audio 1 mic will now be mixed with soundboard output."
