#!/usr/bin/env bash
set -e
echo "Bootstrapping your Arch setup..."

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
stow */  # adjust as needed

echo "Bootstrap complete!"
