#!/usr/bin/env bash
set -euo pipefail

echo "Bootstrapping your Arch setup..."
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Base packages
for pkg in git stow base-devel; do
    if ! pacman -Qq "$pkg" >/dev/null 2>&1; then
        echo "Installing $pkg..."
        sudo pacman -S --needed --noconfirm "$pkg" >/dev/null
    else
        echo "$pkg already installed, skipping..."
    fi
done

# Build yay if missing
(
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT
    cd "$TMPDIR"
    if ! command -v yay >/dev/null 2>&1; then
        echo "Installing yay from AUR..."
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm >/dev/null
    else
        echo "yay already installed, skipping..."
    fi
)

# Install AUR packages
if [[ -f "aur.txt" ]]; then
    echo "Installing AUR packages..."
    while read -r pkg; do
        if ! yay -Qq "$pkg" >/dev/null 2>&1; then
            echo "Installing $pkg..."
            yay -S --needed --noconfirm "$pkg" >/dev/null
        fi
    done < aur.txt
fi

# Install pacman packages (filtered)
if [[ -f "packages.txt" ]]; then
    echo "Installing pacman packages..."
    while read -r pkg; do
        if ! pacman -Qq "$pkg" >/dev/null 2>&1; then
            echo "Installing $pkg..."
            sudo pacman -S --needed --noconfirm "$pkg" >/dev/null
        fi
    done < packages.txt
fi

# Restow directories
echo "Restowing directories..."
for dir in */; do
    stow -R "$dir" >/dev/null || true
done

# Link systemd units if present
SYSTEMD_DIR="system/systemd/system"
if [[ -d "$SYSTEMD_DIR" ]]; then
    echo "Linking systemd units..."
    sudo ln -sf "$SYSTEMD_DIR"/* /etc/systemd/system/
    sudo systemctl daemon-reload
fi

echo "Bootstrap complete!"
