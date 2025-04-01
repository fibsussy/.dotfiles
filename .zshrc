
setopt autocd              # change directory just by typing its name 
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for ‘anything=expression’
setopt nonomatch           # hide error if no pattern match
setopt numericglobsort     # sort filenames numerically
setopt promptsubst         # enable command substitution in prompt
setopt auto_pushd          # push visited dirs to stack
setopt pushd_ignore_dups   # no duplicates in stack
setopt pushd_silent        # silence dir stack output
setopt extended_glob       # enable advanced globbing
setopt histignoredups      # ignore duplicate history entries
setopt complete_in_word    # Allow tab completion mid-word
setopt auto_list           # Show choices on ambiguous completion
setopt auto_menu           # Cycle through tab completions
setopt always_to_end       # Move cursor to end after completion
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



# Log time setup
log_time() {
  if false; then
    local step=$1
    local current_time=$(date +%s%N)
    local elapsed=$(( (current_time - START_TIME) / 1000000 ))  # in milliseconds
    echo "Time taken for $step: ${elapsed} ms"
    START_TIME=$current_time
  fi
}
START_TIME=$(date +%s%N)


tmux_force() {
    # Check if tmux is installed
    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "\033[31mError: tmux is not installed.\033[0m" >&2
        return 1
    fi
    # Check if already in a tmux session
    if [ -n "$TMUX" ]; then
        echo -e "\033[31mError: Already in a tmux session.\033[0m" >&2
        return 1
    fi
    # Try to attach to an existing session or create a new one
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
    # Infinite loop to reattach if detached
    while tmux has-session 2>/dev/null; do
        if ! tmux attach 2>/dev/null; then
            echo -e "\033[31mError: Failed to reattach to tmux.\033[0m" >&2
            return 1
        fi
    done
    return 0
}
# Force tmux in Alacritty
if true \
    && [[ "$TERM" =~ ^(xterm-kitty|alacritty)$ ]] \
    && [[ ! "$TMUX" ]] \
    && [[ "$(tty)" != /dev/tty[0-9]* ]] \
    ; then
    read -k 1 "choice?Do you want to force stay in tmux? [n/Y] "
    case $choice in
        [yY$'\n'])
            tmux_force && exit 0
            ;;
        *)
            echo ""
            echo "Skipping."
            ;;
    esac

fi
log_time "force tmux"




export SSH_ENV="$HOME/.ssh-agent-vars"
start_ssh_agent() {
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" > "$SSH_ENV"
        echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >> "$SSH_ENV"
        chmod 600 "$SSH_ENV"
    else
        echo "Failed to start SSH agent" >&2
        return 1
    fi
}
if [ -f "$SSH_ENV" ]; then
    source "$SSH_ENV" > /dev/null
    if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
        start_ssh_agent
    fi
else
    start_ssh_agent
fi
{ ssh-add -l > /dev/null 2>&1 || ssh-add $(find ~/.ssh/* -type f -name "*.pub" 2>/dev/null | sed 's/\.pub$//' 2>/dev/null) > /dev/null 2>&1; } > /dev/null 2>&1
log_time "ssh agent"


# Functions
paru() {
  command paru --noconfirm "$@"
  command paru -Qqen > ~/packages.txt
}
log_time "paru function"

# Aliases
alias paruclean="sudo pacman -Rsn $(pacman -Qdtq)"
alias brb="clear && figlet BRB | lolcat"
alias l='eza -l  --icons'
alias ls='eza -1  --icons'
alias ll='eza -la --icons'
alias ld='eza -lD --icons'
alias cat='bat'
alias v="/bin/nvim"
alias nightlight="pkill gammastep; gammastep & disown"
alias nightlight_off="pkill gammastep;"
alias stow.="pushd ~/.dotfiles/; stow -D .; stow . --adopt; popd"
alias bgrng='~/Scripts/bgrng.sh'
alias clip="xclip -selection clipboard"

download() {
    if [[ $1 =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
        yt-dlp "$@"
    else
        gallery-dl -D . --cookies-from-browser firefox "$@"
    fi
}

alias c="code"
code() {
    tmux send-keys "nvim" "C-m"
    tmux split-window -h
    # tmux select-pane "-L"
}

log_time "aliases"


# Function to create directory and touch a file
mkdir_and_touch() {
  mkdir -pv "$(dirname "$1")"
  touch "$1"
}
alias touch="mkdir_and_touch"
log_time "mkdir_and_touch function"

# Environment Variables
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"

export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export RUSTFLAGS='-W clippy::pedantic -W clippy::nursery -A clippy::unreadable_literal -A clippy::struct_excessive_bools'

export PATH=$PATH:/home/fib/.cargo/bin
export PATH="$PYENV_ROOT/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

export LANG=en_US.UTF-8
export EDITOR='nvim'
[[ -n $SSH_CONNECTION ]] && export EDITOR='vim'
log_time "environment variables"

load_pyenv() {
  if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)" >/dev/null 2>&1
    eval "$(pyenv init -)" >/dev/null 2>&1
    eval "$(pyenv virtualenv-init -)" >/dev/null 2>&1
  fi
}
if [[ -f .python-version ]]; then
    load_pyenv
fi
log_time "pyenv initialization"

# Install zinit if not already installed
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  echo "Installing ZDHARMA-CONTINUUM Initiative Plugin Manager (zdharma-continuum/zinit)…"
  mkdir -p "$HOME/.local/share/zinit" && chmod g-rwX "$HOME/.local/share/zinit"
  git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
      echo "Installation successful." || \
      echo "The clone has failed."
fi
log_time "zinit installation check"

# Initialize zinit
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
log_time "zinit initialization"

# Load zinit plugins asynchronously
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust \
  zsh-users/zsh-autosuggestions
log_time "zinit plugins load"

# Initialize zinit completion
zicompinit; zicdreplay
log_time "zinit completion initialization"

# Load environment variables from .env files if they exist
set -a
[[ -f .env ]] && source ./.env
[[ -f ./.env.development ]] && source ./.env.development
log_time "loading .env files"

# Initialize starship prompt
eval "$(starship init zsh)"
log_time "starship initialization"

# Lazy load nvm
load_nvm() {
  export NVM_DIR="$HOME/.config/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm() {
  unset -f nvm
  load_nvm
  nvm "$@"
}
log_time "nvm initialization setup"

source <(fzf --zsh)
log_time "fzf source"

autoload -Uz compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc


# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fib/.lmstudio/bin"
