#!/usr/bin/env bash
set -e


if ! pacman -Qq yay >/dev/null 2>&1; then
    (
        tmpdir=$(mktemp -d)
        trap 'rm -rf "$tmpdir"' EXIT
        cd "$tmpdir"
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin
        makepkg -si
    )
fi

if ! pacman -Qq keyboard-middleware >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/fibsussy/keyboard-middleware/main/install.sh | bash
fi

if ! pacman -Qq tmux-leap >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/fibsussy/tmux-leap/main/install.sh | bash
fi

