#!/usr/bin/env bash
set -euo pipefail

echo "Bootstrapping your Arch setup..."

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Running custom package script..."
./packages-custom.sh

echo "Installing pacman packages..."
missing_pkgs=$(comm -23 <(sort packages.txt) <(pacman -Qq | sort))
if [[ -n "$missing_pkgs" ]]; then
    sudo pacman -S --needed --noconfirm $missing_pkgs
fi

echo "Installing AUR packages..."
while IFS= read -r pkg; do
    if ! yay -Qq "$pkg" >/dev/null 2>&1; then
        yay -S --noconfirm "$pkg"
    fi
done < packages-aur.txt

echo "Restowing directories..."
stow -R .

DOTFILES_SYSTEMD="$HOME/.dotfiles/.config/systemd"

# --- Restore system units ---
if [[ -d "$DOTFILES_SYSTEMD/system" ]]; then
    echo "Enabling systemd system units..."
    SYSTEM_STATE_FILE="$DOTFILES_SYSTEMD/system/enabled.list"
    if [[ -f "$SYSTEM_STATE_FILE" ]]; then
        while IFS= read -r u; do
            sudo systemctl enable "$u" || true
        done < "$SYSTEM_STATE_FILE"
    fi
    sudo systemctl daemon-reload
fi

# --- Restore user units ---
if [[ -d "$DOTFILES_SYSTEMD/user" ]]; then
    echo "Enabling systemd user units..."
    USER_STATE_FILE="$DOTFILES_SYSTEMD/user/enabled.list"
    if [[ -f "$USER_STATE_FILE" ]]; then
        while IFS= read -r u; do
            systemctl --user enable "$u" || true
        done < "$USER_STATE_FILE"
    fi
    systemctl --user daemon-reload
fi

echo "Bootstrap complete!"
