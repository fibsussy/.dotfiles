#!/usr/bin/env zsh

# Skip non-interactive shells
[[ -o interactive ]] || return


if [[ -n "$ZSH_PROFILE" ]]; then
    zmodload zsh/zprof
fi

function prompt_stay_at_bottom {
    tput cup $LINES 0 2>/dev/null || true
}

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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

export LESSHISTFILE="${XDG_STATE_HOME}/less/history"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export WGETRC="${XDG_CONFIG_HOME}/wgetrc"
export SCREENRC="$XDG_CONFIG_HOME/screen/screenrc"
export MANPAGER='nvim -c "Man!" -c "set buftype=nofile modifiable"'

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


# Vi Keybindings
bindkey -v                  # Enable vi mode
KEYTIMEOUT=1                # Fast mode switching
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line  # Edit command in editor
bindkey '^r' history-incremental-search-backward  # Ctrl+R for history search


HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=50000
SAVEHIST=10000
setopt appendhistory share_history
setopt hist_expire_dups_first  # Expire duplicates first
setopt hist_ignore_dups        # Ignore consecutive duplicates
setopt hist_ignore_space       # Ignore commands starting with space
setopt hist_verify             # Verify history expansion




fpath=(~/.zfunc $fpath)

autoload -Uz compinit
local comp_dump="${XDG_CACHE_HOME}/zsh/zcompdump"
if [[ -n $ZSH_PROFILE || ! -f "$comp_dump" ]]; then
    compinit -i -d "$comp_dump"
else
    compinit -C -i -d "$comp_dump"
fi


zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
unset zle_bracketed_paste
ZSH_AUTOSUGGEST_STRATEGY=()
ZSH_HIGHLIGHT_MAXLENGTH=0
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}



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

alias sudo='sudo ' # allows aliases with sudo
alias rm='rm -i'
alias tm='trash'
alias cd='z'
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias mkdir='mkdir -pv'
touch() { mkdir -p "$(dirname "$1")" && command touch "$1" ; }
alias l='eza -lh --icons=auto'
alias ls='eza -1 --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lt='eza --icons=auto --tree'
alias cat='bat'
alias v="nvim"
alias paruclean="sudo pacman -Rsn $(pacman -Qdtq 2>/dev/null)"
alias brb="clear && figlet BRB | lolcat"
alias sc='systemctl'
alias scu='systemctl --user'
alias grep='grep --color=auto'
alias fgrep='grep -F --color=auto'
alias egrep='grep -E --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

alias -g H='--help'
alias -g L="| $MANPAGER"
alias -g G='| grep'
alias -g W='| wc'
alias -g J='| jq .'
alias -g C='| tee /dev/tty | perl -pe "chomp if eof" | wl-copy'
alias -g CC='| tee /dev/tty | (echo "❯ $ZSH_COMMAND"; perl -pe "chomp if eof") | wl-copy'
preexec() { ZSH_COMMAND=$1 }
alias -g null='/dev/null'
alias -g 2null='&>null'
alias -g 2bg='&>null & disown'


function load_environment_files() {
    set -a
    [[ -f ~/.api_keys.env ]] && source ~/.api_keys.env
    [[ -f .env ]] && source ./.env
    [[ -f ./.env.dev ]] && source ./.env.dev
    [[ -f ./.env.development ]] && source ./.env.development
    set +a
}
load_environment_files


typeset -g _paru_available
(( $+commands[paru] )) && _paru_available=1
function paru {
    if [[ -n $_paru_available ]]; then
        command paru --noconfirm "$@"
        command paru -Qqen > ~/packages.txt 2>/dev/null
    else
        echo "paru is not installed"
        return 1
    fi
}

typeset -g _ytdlp_available _gallerydl_available
(( $+commands[yt-dlp] )) && _ytdlp_available=1
(( $+commands[gallery-dl] )) && _gallerydl_available=1
function download {
    if [[ $1 =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
        [[ -n $_ytdlp_available ]] && yt-dlp "$@" || { echo "yt-dlp is not installed"; return 1 }
    else
        [[ -n $_gallerydl_available ]] && gallery-dl -D . --cookies-from-browser firefox "$@" || { echo "gallery-dl is not installed"; return 1 }
    fi
}

typeset -g _stow_available
(( $+commands[stow] )) && _stow_available=1
function stow_dotfiles {
    if [[ -n $_stow_available ]]; then
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

# autoload -Uz add-zsh-hook
# add-zsh-hook precmd prompt_stay_at_bottom
eval "$(zoxide init zsh)"
[[ ! -f .p10k.zsh ]] || source .p10k.zsh

[[ -n "$ZSH_PROFILE" ]] && zprof

: # removes the exit 1

