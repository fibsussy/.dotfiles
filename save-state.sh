#!/usr/bin/env bash
set -euo pipefail

echo "Saving current system state into the repo..."
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [[ ! -d .git ]]; then
    echo "Error: Run from the root of your git repo."
    exit 1
fi

echo "Restowing directories..."
for dir in */; do
    stow -R "$dir"
done

echo "Recording installed pacman packages..."
pacman -Qqe | sort > packages.txt

echo "Recording installed AUR packages..."
(
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT
    cd "$TMPDIR"
    if ! command -v yay >/dev/null 2>&1; then
        echo "Installing yay from AUR..."
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
    fi
    yay -Qm | awk '{print $1}' | sort > "$OLDPWD/aur.txt"
)

SYSTEMD_DIR="system/systemd/system"
if [[ -d "$SYSTEMD_DIR" ]]; then
    echo "Systemd units are already in repo; reloading daemon..."
    sudo systemctl daemon-reload
fi

echo "Local state saved! Commit your changes to persist."
