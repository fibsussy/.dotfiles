#!/usr/bin/env bash
set -euo pipefail

echo "Saving current system state into the repo..."

echo "Restowing directories..."
stow -R .

# --- Git-style minimal diff function ---
show_diff() {
    local old="$1"
    local new="$2"
    diff --old-line-format=$'\e[31m- %L\e[0m' \
         --new-line-format=$'\e[32m+ %L\e[0m' \
         --unchanged-line-format='' <(echo "$old") <(echo "$new") || true
}

# --- Record pacman packages ---
echo "Recording installed pacman packages..."
old_pkgs=""
[[ -f packages.txt ]] && old_pkgs=$(<packages.txt)
pacman -Qq | sort > packages.txt
new_pkgs=$(<packages.txt)
show_diff "$old_pkgs" "$new_pkgs"

# --- Record AUR packages ---
echo "Recording installed AUR packages..."
old_aur=""
[[ -f packages-aur.txt ]] && old_aur=$(<packages-aur.txt)
yay -Qqm | sort > packages-aur.txt
new_aur=$(<packages-aur.txt)
show_diff "$old_aur" "$new_aur"

DOTFILES_SYSTEMD="$HOME/.dotfiles/.config/systemd"
mkdir -p "$DOTFILES_SYSTEMD/system" "$DOTFILES_SYSTEMD/user"

# --- Save systemd system units ---
echo "Checking systemd system units..."
SYSTEM_STATE_FILE="$DOTFILES_SYSTEMD/system/enabled.list"
old_system_enabled=""
[[ -f "$SYSTEM_STATE_FILE" ]] && old_system_enabled=$(<"$SYSTEM_STATE_FILE")
systemctl list-unit-files --state=enabled --no-legend --no-pager | awk '{print $1}' | sort > "$SYSTEM_STATE_FILE"
new_system_enabled=$(<"$SYSTEM_STATE_FILE")
show_diff "$old_system_enabled" "$new_system_enabled"

# --- Save systemd user units ---
echo "Checking systemd user units..."
USER_STATE_FILE="$DOTFILES_SYSTEMD/user/enabled.list"
old_user_enabled=""
[[ -f "$USER_STATE_FILE" ]] && old_user_enabled=$(<"$USER_STATE_FILE")
systemctl --user list-unit-files --state=enabled --no-legend --no-pager | awk '{print $1}' | sort > "$USER_STATE_FILE"
new_user_enabled=$(<"$USER_STATE_FILE")
show_diff "$old_user_enabled" "$new_user_enabled"

echo "Local state saved! Commit your changes to persist."
