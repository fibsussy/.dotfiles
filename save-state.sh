#!/usr/bin/env bash
set -euo pipefail

echo "Saving current system state into the repo..."

# --- Git-style minimal diff function ---
show_diff() {
    local old="$1"
    local new="$2"
    diff --old-line-format=$'\e[31m- %L\e[0m' \
         --new-line-format=$'\e[32m+ %L\e[0m' \
         --unchanged-line-format='' <(echo "$old") <(echo "$new") || true
}

# --- Extract words from packages-custom.sh to filter ---
custom_words=$(tr -s '[:space:]' '\n' < packages-custom.sh 2>/dev/null | sort -u || true)

# --- Explicit AUR packages ---
echo "Recording explicit AUR packages..."
old_aur=""
[[ -f packages-aur.txt ]] && old_aur=$(<packages-aur.txt)

yay -Qqme | grep -Fxv -f <(echo "$custom_words") | sort > packages-aur.txt
new_aur=$(<packages-aur.txt)
show_diff "$old_aur" "$new_aur"

# --- Explicit pacman packages ---
echo "Recording explicit pacman packages..."
old_pkgs=""
[[ -f packages.txt ]] && old_pkgs=$(<packages.txt)

pacman -Qqe | grep -Fxv -f <(echo "$custom_words") | sort | comm -23 - packages-aur.txt > packages.txt
new_pkgs=$(<packages.txt)
show_diff "$old_pkgs" "$new_pkgs"

echo "Local state saved! Commit your changes to persist."
