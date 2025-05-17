#!/usr/bin/env zsh

# Skip non-interactive shells
[[ -o interactive ]] || return

if [[ -n "$ZSH_DEBUG" ]]; then
    zsh_start_ms=$(($(date +%s%N 2>/dev/null || gdate +%s%N || (date +%s; echo 000000000)) / 1000000))
    zsh_previous_ms=$zsh_start_ms
fi

function init_timing_log() {
    if [[ -n "$ZSH_DEBUG" ]]; then
        echo -e "\n=== ZSH Startup: $(date) ===\n" > /tmp/zsh_timing.log
        echo -e "SECTION                          TOTAL (ms)   DELTA (ms)   NOTES" >> /tmp/zsh_timing.log
        echo -e "-----------------------------    ----------   ----------   -------------" >> /tmp/zsh_timing.log
    fi
}

function log_timing() {
    if [[ -n "$ZSH_DEBUG" ]]; then
        return;
    fi
    local section_name=$1
    local notes=${2:-}
    local current_ms=$(($(date +%s%N 2>/dev/null || gdate +%s%N || (date +%s; echo 000000000)) / 1000000))
    local elapsed=$((current_ms - zsh_start_ms))
    local delta=$((current_ms - zsh_previous_ms))
    zsh_previous_ms=$current_ms
    if [[ -z "$notes" ]]; then
        printf "%-30s %10d   %10d\n" "${section_name}" $elapsed $delta >> /tmp/zsh_timing.log
    else
        printf "%-30s %10d   %10d   %s\n" "${section_name}" $elapsed $delta "${notes}" >> /tmp/zsh_timing.log
    fi
}

if [[ -n "$ZSH_PROFILE" ]]; then
    zmodload zsh/zprof
    log_timing "profiling_setup"
fi

if [[ -n "$ZSH_DEBUG" ]]; then
    init_timing_log
    log_timing "init"
fi

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export RUSTFLAGS='-W clippy::pedantic -W clippy::nursery -A clippy::unreadable_literal -A clippy::struct_excessive_bools'
export PYENV_ROOT="$HOME/.pyenv"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export LANG=en_US.UTF-8
export EDITOR='nvim'
[[ -n $SSH_CONNECTION ]] && export EDITOR='vim'

path=(
    $HOME/.cargo/bin
    $PYENV_ROOT/bin
    $HOME/.local/bin
    /usr/local/bin
    /usr/local/sbin
    $path
)
export PATH
log_timing "env_vars"

export LESSHISTFILE="${XDG_STATE_HOME}/less/history"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export WGETRC="${XDG_CONFIG_HOME}/wgetrc"
export SCREENRC="$XDG_CONFIG_HOME/screen/screenrc"
log_timing "xdg_compliance"

setopt autocd               # Cd by typing directory name
setopt interactivecomments  # Allow comments in interactive shells
setopt magicequalsubst      # Expand filenames in 'anything=expression'
setopt nonomatch            # Suppress errors on no pattern match
setopt notify               # Report background job status immediately
setopt numericglobsort      # Sort filenames numerically
setopt promptsubst          # Enable command substitution in prompt
setopt auto_pushd           # Push directories to stack
setopt pushd_ignore_dups    # Avoid duplicates in stack
setopt pushd_silent         # Silent pushd/popd
setopt EXTENDED_GLOB        # Enable extended globbing
log_timing "shell_options"


# Vi Keybindings
bindkey -v                  # Enable vi mode
KEYTIMEOUT=1                # Fast mode switching
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line  # Edit command in editor
bindkey '^r' history-incremental-search-backward  # Ctrl+R for history search
log_timing "vi_keybindings"


HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=50000
SAVEHIST=10000
setopt appendhistory share_history
setopt hist_expire_dups_first  # Expire duplicates first
setopt hist_ignore_dups        # Ignore consecutive duplicates
setopt hist_ignore_space       # Ignore commands starting with space
setopt hist_verify             # Verify history expansion
log_timing "history_config"


function prompt_stay_at_bottom {
    tput cup $LINES 0 2>/dev/null || true
}
log_timing "prompt_function"


eval "$(starship init zsh)"
log_timing "starship_init"


function setup_completion() {
    log_timing "pre_compinit"
    fpath=(~/.zfunc $fpath)
    autoload -Uz compinit
    
    local comp_dump="${XDG_CACHE_HOME}/zsh/zcompdump"
    local today=$(date +'%j')
    local comp_day=$(stat -f '%Sm' -t '%j' "$comp_dump" 2>/dev/null || 
                    date -r "$comp_dump" +'%j' 2>/dev/null || 
                    echo "")
    
    if [[ -n "$ZSH_REBUILD_COMPLETION" || ! -f "$comp_dump" || "$today" != "$comp_day" ]]; then
        compinit -i -d "$comp_dump"
    else
        compinit -C -i -d "$comp_dump"
    fi
    
    zstyle ':completion:*' completer _complete _ignored
    zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
    unset zle_bracketed_paste
    ZSH_AUTOSUGGEST_STRATEGY=()
    ZSH_HIGHLIGHT_MAXLENGTH=0
    
    source ~/.config/zsh/fzf-tab/fzf-tab.plugin.zsh
    zmodload zsh/complist
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'j' vi-down-line-or-history
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
    log_timing "compinit"
}


function load_zsh_defer() {
    if [[ ! -f ${ZDOTDIR:-$HOME}/.zsh-defer/zsh-defer.plugin.zsh ]]; then
        curl -s -L https://raw.githubusercontent.com/romkatv/zsh-defer/master/zsh-defer.plugin.zsh > ${ZDOTDIR:-$HOME}/.zsh-defer/zsh-defer.plugin.zsh
    fi
    source ${ZDOTDIR:-$HOME}/.zsh-defer/zsh-defer.plugin.zsh
    log_timing "zsh_defer_load"
}

load_zsh_defer
zsh-defer -c "[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
zsh-defer -c "[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
zsh-defer setup_completion
zsh-defer -c "eval \$(zoxide init zsh)"
log_timing "plugins_lazy_loaded"


function tmux_force {
    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "\033[31mError: tmux is not installed.\033[0m" >&2
        return 1
    fi
    if [ -n "$TMUX" ]; then
        echo -e "\033[31mError: Already in a tmux session.\033[0m" >&2
        return 1
    fi
    if tmux has-session -t '\~' 2>/dev/null; then
        if ! tmux attach-session -t '\~' 2>/dev/null; then
            echo -e "\033[31mError: Failed to attach to tmux session '~'.\033[0m" >&2
            return 1
        fi
    else
        if ! tmux new-session -s '~' -c '~' 2>/dev/null; then
            echo -e "\033[31mError: Failed to create new tmux session '~'.\033[0m" >&2
            return 1
        fi
    fi
    while tmux has-session 2>/dev/null; do
        if ! tmux attach 2>/dev/null; then
            echo -e "\033[31mError: Failed to reattach to tmux.\033[0m" >&2
            return 1
        fi
    done
    return 0
}

function setup_tmux() {
    if [[ "$TERM" =~ ^(xterm-kitty|alacritty)$ ]] && [[ ! "$TMUX" ]] && [[ "$(tty)" != /dev/tty[0-9]* ]]; then
        local rows=$LINES
        local cols=$(tput cols 2>/dev/null || echo 80)
        local p="Do you want to force stay in tmux? [n/Y] "
        local prompt_length=${#p}
        local row=$((rows / 2))
        local col=$(( (cols - prompt_length) / 2 ))
        tput cup $row $col 2>/dev/null || true
        read -k 1 "choice?$p"
        clear
        prompt_stay_at_bottom
        case $choice in
            [yY$'\n']) tmux_force && exit 0 ;;
            *) echo "not using tmux." ;;
        esac
    fi
}
setup_tmux
log_timing "tmux_setup_complete"


function setup_tool_aliases() {
    alias ..='cd ..'
    alias ...='cd ../..'
    alias .3='cd ../../..'
    alias .4='cd ../../../..'
    alias .5='cd ../../../../..'
    alias mkdir='mkdir -p'
    alias touch="mkdir_and_touch"
    alias l='eza -lh --icons=auto'
    alias ls='eza -1 --icons=auto'
    alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
    alias ld='eza -lhD --icons=auto'
    alias lt='eza --icons=auto --tree'
    alias cat='bat'
    alias v="nvim"
    alias nightlight="pkill gammastep 2>/dev/null; gammastep & disown"
    alias nightlight_off="pkill gammastep 2>/dev/null;"
    alias paruclean="sudo pacman -Rsn $(pacman -Qdtq 2>/dev/null)"
    alias clip="xclip -selection clipboard"
    alias brb="clear && figlet BRB | lolcat"
    alias bgrng='~/Scripts/bgrng.sh'
    alias clipout='tee >(wl-copy)'  # Usage: command | clipout
    log_timing "aliases_setup"
}
zsh-defer setup_tool_aliases

alias grep='grep --color=auto'
alias fgrep='grep -F --color=auto'
alias egrep='grep -E --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

function mkdir_and_touch {
    mkdir -pv "$(dirname "$1")"
    touch "$1"
}

function load_environment_files() {
    set -a
    [[ -f ~/.api_keys.env ]] && source ~/.api_keys.env
    [[ -f .env ]] && source ./.env
    [[ -f ./.env.dev ]] && source ./.env.dev
    [[ -f ./.env.development ]] && source ./.env.development
    set +a
    log_timing "env_files_loaded"
}
load_environment_files

function paru {
    if (( $+commands[paru] )); then
        command paru --noconfirm "$@"
        command paru -Qqen > ~/packages.txt 2>/dev/null
    else
        echo "paru is not installed"
        return 1
    fi
}

function download {
    if [[ $1 =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
        if (( $+commands[yt-dlp] )); then
            yt-dlp "$@"
        else
            echo "yt-dlp is not installed"
            return 1
        fi
    else
        if (( $+commands[gallery-dl] )); then
            gallery-dl -D . --cookies-from-browser firefox "$@"
        else
            echo "gallery-dl is not installed"
            return 1
        fi
    fi
}

function stow_dotfiles {
    if (( $+commands[stow] )); then
        local trapped_dir=$(pwd)
        trap "cd $trapped_dir" EXIT
        cd ~/.dotfiles/ 2>/dev/null || { echo "~/.dotfiles directory not found"; return 1; }
        stow -D .
        stow . --adopt
    else
        echo "stow is not installed"
        return 1
    fi
}

function start_ssh_agent {
    SSH_KEYS=$(grep -lZ -- "-----BEGIN.*PRIVATE KEY-----" ~/.ssh/* | tr '\0' '\n')
    eval $(keychain --agents ssh --eval --quiet)
    while IFS= read -r key; do
        [ -z "$key" ] && continue
        [ ! -e "$key" ] && continue
        local target=$(readlink -f "$key" 2>/dev/null || realpath "$key" 2>/dev/null)
        [ -z "$target" ] && target="$key"
        local perm=$(stat -c %a "$target" 2>/dev/null)
        if [ "$perm" != "600" ]; then
            echo "Fixing permissions for $target (linked from $key)"
            sudo chmod 600 "$target"
        fi
    done <<< "$SSH_KEYS"
    echo "$SSH_KEYS" | xargs ssh-add 2>/dev/null
}
zsh-defer start_ssh_agent

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_stay_at_bottom
log_timing "hooks_setup"

if [[ -n "$ZSH_DEBUG" && -f /tmp/zsh_timing.log ]]; then
    local current_ms=$(($(date +%s%N 2>/dev/null || gdate +%s%N || (date +%s; echo 000000000)) / 1000000))
    local total_ms=$((current_ms - zsh_start_ms))
    local total_s=$((total_ms / 1000))
    local total_ms_remainder=$((total_ms % 1000))
    echo -e "\n------------------------------------------------------------" >> /tmp/zsh_timing.log
    echo -e "Total startup time: ${total_s}.${total_ms_remainder}s (${total_ms}ms)" >> /tmp/zsh_timing.log
    echo -e "------------------------------------------------------------" >> /tmp/zsh_timing.log
    echo "Shell startup timing report:"
    echo "============================================================"
    cat /tmp/zsh_timing.log
    echo "============================================================"
    if (( total_s > 3 )); then
        echo -e "\n⚠️ Warning: Shell startup took more than 3 seconds. Consider optimizing:"
        echo "1. Run ZSH_DEBUG=1 zsh -i -c exit for detailed timing"
        echo "2. Run ZSH_PROFILE=1 zsh -i -c exit for function-level profiling"
    fi
fi

[[ -n "$ZSH_PROFILE" ]] && zprof
