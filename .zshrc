#!/usr/bin/env zsh


zsh_start_time=$SECONDS


function prompt_stay_at_bottom {
    tput cup $LINES 0
}
prompt_stay_at_bottom

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


# Force tmux in Alacritty
if [[ "$TERM" =~ ^(xterm-kitty|alacritty)$ ]] && [[ ! "$TMUX" ]] && [[ "$(tty)" != /dev/tty[0-9]* ]]; then
    local rows=$LINES
    local cols=$(tput cols)
    local p="Do you want to force stay in tmux? [n/Y] "
    prompt_length=${#p}
    local row=$((rows / 2))  # Middle row
    local col=$(( (cols - prompt_length) / 2 ))  # Middle column, adjusted for prompt length
    tput cup $row $col
    read -k 1 "choice?Do you want to force stay in tmux? [n/Y] "
    clear
    prompt_stay_at_bottom
    case $choice in
        [yY$'\n'])
            tmux_force && exit 0
            ;;
        *)
            echo "not using tmux."
            ;;
    esac
fi



# Timing function to log module load times
function _log_timing() {
    local module_name=$1
    local elapsed=$(( (SECONDS - zsh_start_time) * 1000 ))
    printf "TIMING: %-30s %5d ms\n" "${module_name}" $elapsed >> /tmp/zsh_timing.log
}

# Initialize timing log
function _init_timing_log() {
    echo -e "\n=== ZSH Startup: $(date) ===\n" > /tmp/zsh_timing.log
}
_init_timing_log

# Function to debug timing at the end
function _debug_timing() {
    if [[ -f /tmp/zsh_timing.log ]]; then
        echo "Shell startup timing report:"
        cat /tmp/zsh_timing.log
        
        # Calculate total time
        local total_time=$(( SECONDS - zsh_start_time ))
        echo -e "\nTotal startup time: ${total_time}s"
    fi
}


_log_timing "init"


# Enable profiling if ZSH_PROFILE=1
[[ -n "$ZSH_PROFILE" ]] && zmodload zsh/zprof

# Initialization flags
typeset -A _HYDE_INIT_FLAGS

# Load zsh-defer for async loading
if [[ ! -f ${ZDOTDIR:-$HOME}/.zsh-defer/zsh-defer.plugin.zsh ]]; then
    mkdir -p ${ZDOTDIR:-$HOME}/.zsh-defer
    curl -L https://raw.githubusercontent.com/romkatv/zsh-defer/master/zsh-defer.plugin.zsh > ${ZDOTDIR:-$HOME}/.zsh-defer/zsh-defer.plugin.zsh
fi
source ${ZDOTDIR:-$HOME}/.zsh-defer/zsh-defer.plugin.zsh
_log_timing "zsh_defer_load"

#  Environment Variables 
# --------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"

export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export RUSTFLAGS='-W clippy::pedantic -W clippy::nursery -A clippy::unreadable_literal -A clippy::struct_excessive_bools'
export PATH=$PATH:/home/fib/.cargo/bin
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export LANG=en_US.UTF-8
export EDITOR='nvim'
[[ -n $SSH_CONNECTION ]] && export EDITOR='vim'

# Clean up home folder
LESSHISTFILE=${LESSHISTFILE:-/tmp/less-hist}
PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
WGETRC="${XDG_CONFIG_HOME}/wgetrc"
SCREENRC="$XDG_CONFIG_HOME"/screen/screenrc

#  Plugin Configuration 
# -------------------------
function load_zsh_plugins {
    if [[ "${_HYDE_INIT_FLAGS[zsh_plugins]}" != "1" ]]; then
        _HYDE_INIT_FLAGS[zsh_plugins]=1
        
        # Oh-my-zsh installation path
        zsh_paths=(
            "$HOME/.oh-my-zsh"
            "/usr/local/share/oh-my-zsh"
            "/usr/share/oh-my-zsh"
        )
        for zsh_path in "${zsh_paths[@]}"; do 
            [[ -d $zsh_path ]] && export ZSH=$zsh_path && break
        done
        
        # Load minimal plugins - removed problematic plugins that cause pasting issues
        hyde_plugins=(git zsh-256color)
        # Removed sudo plugin which causes auto-expansion
        # Removed zsh-autosuggestions and zsh-syntax-highlighting which cause pasting issues
        plugins+=("${hyde_plugins[@]}")
        # Deduplicate plugins
        plugins=($(printf "%s\n" "${plugins[@]}" | sort -u))

        #env STARSHIP_LOG=trace starship timings  
        local omz_start=$SECONDS
        [[ -r $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh
        local omz_time=$(( (SECONDS - omz_start) * 1000 ))
        _log_timing "oh_my_zsh_load:${omz_time}ms"
    fi
}

#  Shell Options 
# ------------------
setopt autocd              # change directory just by typing its name 
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for 'anything=expression'
setopt nonomatch           # hide error if no pattern match
setopt numericglobsort     # sort filenames numerically
setopt promptsubst         # enable command substitution in prompt
setopt auto_pushd          # push visited dirs to stack
setopt pushd_ignore_dups   # no duplicates in stack
setopt pushd_silent        # silence dir stack output
setopt extended_glob       # enable advanced globbing
setopt histignoredups      # ignore duplicate history entries
setopt complete_in_word    # Allow tab completion mid-word
setopt no_hist_expand      # Disable immediate history expansion (fixes !! + space issue)
# Disabled aggressive completion options that can interfere with pasting
# setopt auto_list         # Show choices on ambiguous completion
# setopt auto_menu         # Cycle through tab completions
# setopt always_to_end     # Move cursor to end after completion
setopt list_packed         # Compact completion lists
setopt mark_dirs           # Append / to dir names during globbing
setopt bare_glob_qual      # Allow glob qualifiers without parentheses
setopt multios             # Allow multiple redirections (>a >b)
setopt no_hup              # Don't kill bg jobs on shell exit
setopt long_list_jobs      # Show PID in job listings
setopt notify              # You already have this - keep it!
setopt no_beep             # Disable beeping
setopt transient_rprompt   # Right prompt disappears after command
setopt clobber             # Allow > to overwrite files (safer alternative to noclobber)

#  Functions 
# --------------
function slow_load_warning {
    local lock_file="/tmp/.hyde_slow_load_warning.lock"
    local load_time=$SECONDS

    if [[ ! -f $lock_file ]]; then
        touch $lock_file
        time_limit=3
        if ((load_time > time_limit)); then
            cat <<EOF
⚠️ Warning: Shell startup took more than ${time_limit} seconds. Consider optimizing:
1. Remove duplicate plugin initializations
2. Check for slow initialization scripts
3. Ensure ~/.zshrc doesn't duplicate HyDE configurations
4. Run with ZSH_PROFILE=1 zsh -i -c exit to profile startup
5. Consider lazy-loading more components
6. Run '_debug_timing' to see detailed timing information
EOF
            # Show top 5 slowest operations if profiling is enabled
            if [[ -n "$ZSH_PROFILE" ]]; then
                echo "\nTop 5 slowest operations:"
                zprof | head -n 10
            fi
            
            # Show timing information
            _debug_timing
        fi
    fi
}

function no_such_file_or_directory_handler {
    local red='\e[1;31m' reset='\e[0m'
    printf "${red}zsh: no such file or directory: %s${reset}\n" "$1"
    return 127
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

function paru {
    command paru --noconfirm "$@"
    command paru -Qqen > ~/packages.txt
}

function download {
    if [[ $1 =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
        yt-dlp "$@"
    else
        gallery-dl -D . --cookies-from-browser firefox "$@"
    fi
}

function code {
    if [ -z "$TMUX" ]; then
        local red='\e[1;31m' reset='\e[0m'
        printf "${red}Error: 'code' command requires to be in a tmux session${reset}\n"
        return 1
    fi
    tmux split-window -h -b
    tmux send-keys "nvim" "C-m"
}

function mkdir_and_touch {
    mkdir -pv "$(dirname "$1")"
    touch "$1"
}

function load_pyenv {
    if [[ "${_HYDE_INIT_FLAGS[pyenv]}" != "1" ]]; then
        _HYDE_INIT_FLAGS[pyenv]=1
        
        if command -v pyenv 1>/dev/null 2>&1; then
            eval "$(pyenv init --path)" >/dev/null 2>&1
            eval "$(pyenv init -)" >/dev/null 2>&1
            eval "$(pyenv virtualenv-init -)" >/dev/null 2>&1
        fi
    fi
}

function load_nvm {
    if [[ "${_HYDE_INIT_FLAGS[nvm]}" != "1" ]]; then
        _HYDE_INIT_FLAGS[nvm]=1
        
        export NVM_DIR="$HOME/.config/nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi
}

#  Aliases 
# ------------
alias l='eza -lh --icons=auto'
alias ls='eza -1 --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lt='eza --icons=auto --tree'
alias cat='bat'
alias v="/bin/nvim"
alias nightlight="pkill gammastep; gammastep & disown"
alias nightlight_off="pkill gammastep;"
alias stow.="pushd ~/.dotfiles/; stow -D .; stow . --adopt; popd"
alias bgrng='~/Scripts/bgrng.sh'
alias clip="xclip -selection clipboard"
alias c="code"
alias paruclean="sudo pacman -Rsn $(pacman -Qdtq)"
alias brb="clear && figlet BRB | lolcat"
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias mkdir='mkdir -p'
alias touch="mkdir_and_touch"

#  Initialization 
# -------------------
if [ -t 1 ]; then
    start_ssh_agent

    # Load plugins
    _log_timing "pre_plugins"
    load_zsh_plugins
    _log_timing "plugins_loaded"
    
    # Set up hooks
    autoload -Uz add-zsh-hook
    add-zsh-hook -Uz precmd slow_load_warning
    add-zsh-hook precmd prompt_stay_at_bottom
    _log_timing "hooks_setup"


    # Load pyenv if .python-version exists
    if [[ -f .python-version ]]; then
        load_pyenv
    fi

    # Lazy load nvm
    nvm() {
        unset -f nvm
        load_nvm
        nvm "$@"
    }

    # Disabled zinit plugins which can cause pasting issues
    if [[ -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
        _log_timing "pre_zinit"
        source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
        autoload -Uz _zinit
        (( ${+_comps} )) && _comps[zinit]=_zinit
        
        zinit light-mode for \
            zdharma-continuum/zinit-annex-as-monitor \
            zdharma-continuum/zinit-annex-bin-gem-node \
            zdharma-continuum/zinit-annex-patch-dl \
            zdharma-continuum/zinit-annex-rust
            # Removed zsh-autosuggestions which causes pasting issues
        
        zicompinit; zicdreplay
        _log_timing "zinit_loaded"
    fi

    # Load environment files
    set -a
    [[ -f ~/.api_keys.env ]] && source ~/.api_keys.env
    [[ -f .env ]] && source ./.env
    [[ -f ./.env.dev ]] && source ./.env.dev
    [[ -f ./.env.development ]] && source ./.env.development

# Initialize starship prompt
    _log_timing "pre_starship"
    eval "$(starship init zsh)"
    _log_timing "starship_init"

    # Source fzf
    _log_timing "pre_fzf"
    source <(fzf --zsh)
    _log_timing "fzf_init"

    # Simplified completion system
    _log_timing "pre_compinit"
    autoload -Uz compinit
    # Disabled menu select which can interfere with pasting
    # zstyle ':completion:*' menu select
    fpath+=~/.zfunc
    _log_timing "compinit"
    
    # Fix for pasting issues
    # This disables the "bracketed paste" feature which can cause problems
    unset zle_bracketed_paste
    
    # Disable auto-suggestions and syntax highlighting from affecting pasting
    ZSH_AUTOSUGGEST_STRATEGY=()
    ZSH_HIGHLIGHT_MAXLENGTH=0
fi
