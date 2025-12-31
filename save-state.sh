#!/usr/bin/env bash
set -e
echo "Saving current system state into the repo..."

echo "Restowing directories..."
stow */  # adjust as needed

echo "Recording installed pacman packages..."
pacman -Qq | sort > packages.txt

echo "Recording installed AUR packages..."
yay -Qqm | sort > packages-aur.txt

echo "Local state saved! Commit your changes to persist."
