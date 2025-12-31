#!/usr/bin/env bash
set -e

if ! yay -Qq keyboard-middleware >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/fibsussy/keyboard-middleware/main/install.sh | bash
fi

if ! yay -Qq tmux-leap >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/fibsussy/tmux-leap/main/install.sh | bash
fi

