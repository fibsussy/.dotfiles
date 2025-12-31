#!/usr/bin/env bash
set -euo pipefail

echo "Bootstrapping your Arch setup..."

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- diff helper ---
show_diff() {
    local old="$1"
    local new="$2"
    diff --old-line-format=$'\e[31m- %L\e[0m' \
         --new-line-format=$'\e[32m+ %L\e[0m' \
         --unchanged-line-format='' \
         <(echo "$old") <(echo "$new") || true
}

echo "Running custom package script..."
./packages-custom.sh

# --- Explicit packages ---
echo "Installing explicit pacman packages..."
missing_pkgs=$(comm -23 <(sort packages.txt) <(pacman -Qq | sort))
if [[ -n "$missing_pkgs" ]]; then
    sudo pacman -S --needed --noconfirm $missing_pkgs
fi

# --- AUR packages ---
echo "Installing explicit AUR packages..."
while IFS= read -r pkg; do
    if ! yay -Qq "$pkg" >/dev/null 2>&1; then
        yay -S --noconfirm "$pkg"
    fi
done < packages-aur.txt

echo "Restowing directories..."
stow -R .

DOTFILES_SYSTEMD="$HOME/.dotfiles/.config/systemd"

# --- system units ---
if [[ -f "$DOTFILES_SYSTEMD/system/enabled.list" ]]; then
    echo "Reconciling systemd system units..."

    before=$(systemctl list-unit-files --state=enabled --no-legend --no-pager | awk '{print $1}' | sort)
    desired=$(sort "$DOTFILES_SYSTEMD/system/enabled.list")

    comm -23 <(echo "$desired") <(echo "$before") | while read -r u; do
        sudo systemctl enable "$u" || true
    done

    comm -13 <(echo "$desired") <(echo "$before") | while read -r u; do
        sudo systemctl disable "$u" || true
    done

    after=$(systemctl list-unit-files --state=enabled --no-legend --no-pager | awk '{print $1}' | sort)
    show_diff "$before" "$after"

    sudo systemctl daemon-reload
fi

# --- user units ---
if [[ -f "$DOTFILES_SYSTEMD/user/enabled.list" ]]; then
    echo "Reconciling systemd user units..."

    before=$(systemctl --user list-unit-files --state=enabled --no-legend --no-pager | awk '{print $1}' | sort)
    desired=$(sort "$DOTFILES_SYSTEMD/user/enabled.list")

    comm -23 <(echo "$desired") <(echo "$before") | while read -r u; do
        systemctl --user enable "$u" || true
    done

    comm -13 <(echo "$desired") <(echo "$before") | while read -r u; do
        systemctl --user disable "$u" || true
    done

    after=$(systemctl --user list-unit-files --state=enabled --no-legend --no-pager | awk '{print $1}' | sort)
    show_diff "$before" "$after"

    systemctl --user daemon-reload
fi

echo "Bootstrap complete!"
echo ""
echo -e "\e[33mRuntime state not fully applied.\e[0m"
echo -e "\e[33mEnabled units now match the repo, but running services may differ.\e[0m"
echo ""
echo -e "\e[36mRecommended (clean + safe):\e[0m"
echo -e "  \e[32msudo reboot\e[0m"
