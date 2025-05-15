#!/usr/bin/env zsh

# Skip non-interactive shells
[[ -o interactive ]] || return

# Debug timing setup
if [[ -n "$ZSH_DEBUG" ]]; then
    zsh_start_ms=$(($(date +%s%N 2>/dev/null || gdate +%s%N || (date +%s; echo 000000000)) / 1000000))
    zsh_previous_ms=$zsh_start_ms
fi

# Initialize timing log
function init_timing_log() {
    if [[ -n "$ZSH_DEBUG" ]]; then
        echo -e "\n=== ZSH Startup: $(date) ===\n" > /tmp/zsh_timing.log
        echo -e "SECTION                          TOTAL (ms)   DELTA (ms)   NOTES" >> /tmp/zsh_timing.log
        echo -e "-----------------------------    ----------   ----------   -------------" >> /tmp/zsh_timing.log
    fi
}

# Log module load times
function log_timing() {
    if [[ -n "$ZSH_DEBUG" ]]; then
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
    fi
}


# Profiling setup
if [[ -n "$ZSH_PROFILE" ]]; then
    zmodload zsh/zprof
    [[ -n "$ZSH_DEBUG" ]] && log_timing "profiling_setup"
fi

# Initialize timing
if [[ -n "$ZSH_DEBUG" ]]; then
    init_timing_log
    log_timing "init"
fi

# Initialization flags
typeset -A INIT_FLAGS
[[ -n "$ZSH_DEBUG" ]] && log_timing "init_flags"

# Environment Variables
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

# Consolidated PATH
path=(
    $HOME/.cargo/bin
    $PYENV_ROOT/bin
    $HOME/.local/bin
    /usr/local/bin
    /usr/local/sbin
    $path
)
export PATH
[[ -n "$ZSH_DEBUG" ]] && log_timing "env_vars"

# XDG compliance
export LESSHISTFILE="${XDG_STATE_HOME}/less/history"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export WGETRC="${XDG_CONFIG_HOME}/wgetrc"
export SCREENRC="$XDG_CONFIG_HOME/screen/screenrc"
[[ -n "$ZSH_DEBUG" ]] && log_timing "xdg_compliance"

# Shell Options
setopt autocd interactivecomments magicequalsubst nonomatch numericglobsort promptsubst auto_pushd pushd_ignore_dups pushd_silent extended_glob histignoredups complete_in_word no_hist_expand list_packed mark_dirs bare_glob_qual multios no_hup long_list_jobs notify no_beep transient_rprompt clobber
setopt HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS
[[ -n "$ZSH_DEBUG" ]] && log_timing "shell_options"

# Fix terminal positioning
function prompt_stay_at_bottom {
    tput cup $LINES 0 2>/dev/null || true
}
[[ -n "$ZSH_DEBUG" ]] && log_timing "prompt_stay_at_bottom"

# History configuration
HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=50000
SAVEHIST=10000
setopt appendhistory share_history
[[ -n "$ZSH_DEBUG" ]] && log_timing "history_config"

# Load zsh-defer
function load_zsh_defer() {
    if [[ ! -f ${ZDOTDIR:-$HOME}/.zsh-defer/zsh-defer.plugin.zsh ]]; then
        curl -s -L https://raw.githubusercontent.com/romkatv/zsh-defer/master/zsh-defer.plugin.zsh > ${ZDOTDIR:-$HOME}/.zsh-defer/zsh-defer.plugin.zsh
    fi
    source ${ZDOTDIR:-$HOME}/.zsh-defer/zsh-defer.plugin.zsh
    [[ -n "$ZSH_DEBUG" ]] && log_timing "zsh_defer_load"
}

# Core Functions
function no_such_file_or_directory_handler {
    local red='\e[1;31m' reset='\e[0m'
    printf "${red}zsh: no such file or directory: %s${reset}\n" "$1"
    return 127
}
[[ -n "$ZSH_DEBUG" ]] && log_timing "no_such_file_handler"

function mkdir_and_touch {
    mkdir -pv "$(dirname "$1")"
    touch "$1"
}
[[ -n "$ZSH_DEBUG" ]] && log_timing "mkdir_and_touch"

# TMUX function
function tmux_force {
    if ! (( $+commands[tmux] )); then
        echo -e "\033[31mError: tmux is not installed.\033[0m" >&2
        return 1
    fi
    if [ -n "$TMUX" ]; then
        echo -e "\033[31mError: Already in a tmux session.\033[0m" >&2
        return 1
    fi
    if tmux has-session -t '\~' 2>/dev/null; then
        tmux attach-session -t '\~' 2>/dev/null || return 1
    else
        tmux new-session -s '~' -c '~' 2>/dev/null || return 1
    fi
    while tmux has-session 2>/dev/null; do
        tmux attach 2>/dev/null || return 1
    done
    return 0
}
[[ -n "$ZSH_DEBUG" ]] && log_timing "tmux_force"

# TMUX setup
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

# Core aliases
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias mkdir='mkdir -p'
alias touch="mkdir_and_touch"
[[ -n "$ZSH_DEBUG" ]] && log_timing "core_aliases"

# Load environment files
function load_environment_files() {
    set -a
    [[ -f ~/.api_keys.env ]] && source ~/.api_keys.env
    [[ -f .env ]] && source ./.env
    [[ -f ./.env.dev ]] && source ./.env.dev
    [[ -f ./.env.development ]] && source ./.env.development
    set +a
    [[ -n "$ZSH_DEBUG" ]] && log_timing "env_files_loaded"
}

# Lazy loading
function load_pyenv {
    if [[ "${INIT_FLAGS[pyenv]}" != "1" ]]; then
        INIT_FLAGS[pyenv]=1
        if (( $+commands[pyenv] )); then
            eval "$(pyenv init --path)" >/dev/null 2>&1
            eval "$(pyenv init -)" >/dev/null 2>&1
            eval "$(pyenv virtualenv-init -)" >/dev/null 2>&1
        fi
    fi
}
[[ -n "$ZSH_DEBUG" ]] && log_timing "load_pyenv"

function load_nvm {
    if [[ "${INIT_FLAGS[nvm]}" != "1" ]]; then
        INIT_FLAGS[nvm]=1
        export NVM_DIR="$HOME/.config/nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi
}
[[ -n "$ZSH_DEBUG" ]] && log_timing "load_nvm"

# Tool-dependent aliases
function setup_tool_aliases() {
    if (( $+commands[eza] )); then
        alias l='eza -lh --icons=auto'
        alias ls='eza -1 --icons=auto'
        alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
        alias ld='eza -lhD --icons=auto'
        alias lt='eza --icons=auto --tree'
    fi
    if (( $+commands[bat] )); then
        alias cat='bat'
    fi
    if (( $+commands[nvim] )); then
        alias v="nvim"
    fi
    if (( $+commands[gammastep] )); then
        alias nightlight="pkill gammastep 2>/dev/null; gammastep & disown"
        alias nightlight_off="pkill gammastep 2>/dev/null;"
    fi
    if (( $+commands[paru] )); then
        alias paruclean="sudo pacman -Rsn $(pacman -Qdtq 2>/dev/null)"
    fi
    if (( $+commands[xclip] )); then
        alias clip="xclip -selection clipboard"
    fi
    if (( $+commands[figlet] )) && (( $+commands[lolcat] )); then
        alias brb="clear && figlet BRB | lolcat"
    fi
    [[ -f ~/Scripts/bgrng.sh ]] && alias bgrng='~/Scripts/bgrng.sh'
    [[ -n "$ZSH_DEBUG" ]] && log_timing "aliases_setup"
}

# SSH agent
function start_ssh_agent {
    if (( $+commands[ssh-agent] )) && (( $+commands[keychain] )); then
        local SSH_KEYS=$(find ~/.ssh -type f -exec grep -l -- "-----BEGIN.*PRIVATE KEY-----" {} \; 2>/dev/null)
        eval $(keychain --eval --quiet)
        echo "$SSH_KEYS" | while IFS= read -r key; do
            [ -z "$key" ] || [ ! -e "$key" ] && continue
            local target=$(readlink -f "$key" 2>/dev/null || realpath "$key" 2>/dev/null || echo "$key")
            local perm=$(stat -c %a "$target" 2>/dev/null)
            if [ "$perm" != "600" ]; then
                chmod 600 "$target" 2>/dev/null || sudo chmod 600 "$target" 2>/dev/null
            fi
        done
        echo "$SSH_KEYS" | xargs -r ssh-add 2>/dev/null
    fi
    [[ -n "$ZSH_DEBUG" ]] && log_timing "ssh_agent_complete"
}

# Enhanced parc
function paru {
    if (( $+commands[paru] )); then
        command paru --noconfirm "$@"
        command paru -Qqen > ~/packages.txt 2>/dev/null
    else
        echo "paru is not installed"
        return 1
    fi
}
[[ -n "$ZSH_DEBUG" ]] && log_timing "paru_function"

# Download helper
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
[[ -n "$ZSH_DEBUG" ]] && log_timing "download_function"

# Stow dotfiles
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
[[ -n "$ZSH_DEBUG" ]] && log_timing "stow_dotfiles"

# Completion system
function setup_completion() {
    [[ -n "$ZSH_DEBUG" ]] && log_timing "pre_compinit"
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
    [[ -n "$ZSH_DEBUG" ]] && log_timing "compinit"
}

# Load plugins
function load_zsh_plugins {
    if [[ "${INIT_FLAGS[zsh_plugins]}" != "1" ]]; then
        INIT_FLAGS[zsh_plugins]=1
        [[ -n "$ZSH_DEBUG" ]] && log_timing "pre_plugins"
        
        # Use zinit for git plugin if available (faster)
        if [[ -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
            zinit ice wait lucid
            zinit snippet OMZ::plugins/git/git.plugin.zsh
        # Fall back to oh-my-zsh
        else
            local zsh_found=0
            for zsh_path in "$HOME/.oh-my-zsh" "/usr/local/share/oh-my-zsh" "/usr/share/oh-my-zsh"; do
                if [[ -d $zsh_path ]]; then
                    export ZSH=$zsh_path
                    zsh_found=1
                    break
                fi
            done
            if [[ $zsh_found -eq 1 && -r $ZSH/oh-my-zsh.sh ]]; then
                plugins=(git)
                DISABLE_MAGIC_FUNCTIONS=true
                DISABLE_AUTO_UPDATE=true
                DISABLE_UNTRACKED_FILES_DIRTY=true
                source $ZSH/oh-my-zsh.sh
            fi
        fi
        [[ -n "$ZSH_DEBUG" ]] && log_timing "plugins_loaded"
    fi
}

# Zinit setup
function load_zinit {
    if [[ "${INIT_FLAGS[zinit]}" != "1" && -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
        INIT_FLAGS[zinit]=1
        [[ -n "$ZSH_DEBUG" ]] && log_timing "pre_zinit"
        source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
        autoload -Uz _zinit
        (( ${+_comps} )) && _comps[zinit]=_zinit
        zinit light-mode for zdharma-continuum/zinit-annex-bin-gem-node
        zicompinit; zicdreplay
        [[ -n "$ZSH_DEBUG" ]] && log_timing "zinit_loaded"
    fi
}

# Slow load warning
function slow_load_warning {
    if [[ -n "$ZSH_DEBUG" ]]; then
        local current_ms=$(($(date +%s%N 2>/dev/null || gdate +%s%N || (date +%s; echo 000000000)) / 1000000))
        local total_ms=$((current_ms - zsh_start_ms))
        local total_s=$((total_ms / 1000))
        time_limit=3
        if ((total_s > time_limit)); then
            cat <<EOF
⚠️ Warning: Shell startup took more than ${time_limit} seconds. Consider optimizing:
1. Run ZSH_DEBUG=1 zsh -i -c exit for detailed timing
2. Run ZSH_PROFILE=1 zsh -i -c exit for function-level profiling
3. Run 'debug_timing' to see startup timing breakdown
EOF
        fi
        debug_timing
    fi
}

# Starship prompt
function setup_starship {
    [[ -n "$ZSH_DEBUG" ]] && log_timing "pre_starship"
    if (( $+commands[starship] )); then
        eval "$(starship init zsh)"
    fi
    [[ -n "$ZSH_DEBUG" ]] && log_timing "starship_init"
}

# FZF initialization
function setup_fzf {
    [[ -n "$ZSH_DEBUG" ]] && log_timing "pre_fzf"
    if (( $+commands[fzf] )); then
        source <(fzf --zsh 2>/dev/null)
    fi
    [[ -n "$ZSH_DEBUG" ]] && log_timing "fzf_init"
}

# Lazy NVM
function setup_lazy_nvm {
    nvm() {
        unset -f nvm
        load_nvm
        nvm "$@"
    }
    [[ -n "$ZSH_DEBUG" ]] && log_timing "nvm_setup"
}

if [[ -n "$ZSH_DEBUG" ]]; then
    log_timing "interactive_start"
fi
setup_tmux
[[ -n "$ZSH_DEBUG" ]] && log_timing "tmux_setup_complete"
load_environment_files
setup_starship

# Defer everything possible
load_zsh_defer
if type zsh-defer >/dev/null 2>&1; then
    zsh-defer -c "[[ -f .python-version ]] && load_pyenv"
    zsh-defer setup_lazy_nvm
    zsh-defer setup_completion
    zsh-defer setup_fzf
    zsh-defer start_ssh_agent
    zsh-defer setup_tool_aliases
    zsh-defer load_zsh_plugins
    zsh-defer load_zinit
else
    [[ -f .python-version ]] && load_pyenv
    setup_lazy_nvm
    setup_completion
    setup_fzf
    start_ssh_agent
    setup_tool_aliases
    load_zsh_plugins
    load_zinit
fi
[[ -n "$ZSH_DEBUG" ]] && log_timing "deferred_loading"

autoload -Uz add-zsh-hook
add-zsh-hook -Uz precmd slow_load_warning
add-zsh-hook precmd prompt_stay_at_bottom
[[ -n "$ZSH_DEBUG" ]] && log_timing "hooks_setup"
[[ -n "$ZSH_DEBUG" ]] && log_timing "init_complete"

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
fi


# Run profiling at the end
[[ -n "$ZSH_PROFILE" ]] && zprof
