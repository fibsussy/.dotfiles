#!/usr/bin/env zsh

# XDG Base Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=${HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:=${HOME}/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:=${HOME}/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:=${HOME}/.local/state}"

# ZSH config location
export ZDOTDIR="${ZDOTDIR:=${XDG_CONFIG_HOME}/zsh}"

# Tool-specific XDG migrations
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-/run/user/$(id -u)/ssh-agent.socket}"
export HISTFILE="$XDG_STATE_HOME/bash/history"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export SCREENRC="$XDG_CONFIG_HOME/screen/screenrc"

# Prevent programs from recreating ~/ dotfiles
export __GL_SHADER_DISK_CACHE_PATH="$XDG_CACHE_HOME/nv"
export PULSE_COOKIE="$XDG_CONFIG_HOME/pulse/cookie"

if ! source $ZDOTDIR/.zshenv; then
    echo "FATAL Error: Could not source $ZDOTDIR/.zshenv"
    return 1
fi
