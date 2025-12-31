#!/usr/bin/env bash
set -e

echo "Setting up remote dotfiles repo..."

# Clone the repo if it doesn't exist
if [ ! -d "$HOME/.dotfiles" ]; then
    git clone <YOUR_REMOTE_URL> "$HOME/.dotfiles"
else
    echo "Repo already exists. Pulling latest changes..."
    git -C "$HOME/.dotfiles" pull
fi
