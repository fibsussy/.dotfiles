# Function to log elapsed time
ENABLE_TIMING=false
log_time() {
  if $ENABLE_TIMING; then
    local step=$1
    local current_time=$(date +%s%N)
    local elapsed=$(( (current_time - START_TIME) / 1000000 ))  # in milliseconds
    echo "Time taken until $step: ${elapsed} ms"
    START_TIME=$current_time
  fi
}
START_TIME=$(date +%s%N)

# Functions
paru() {
  command paru --noconfirm "$@"
  command paru -Qqen > ~/packages.txt
}
log_time "after paru function"

# Aliases
alias paruclean="sudo pacman -Rsn $(pacman -Qdtq)"
alias brb="clear && figlet BRB | lolcat"
alias l='eza -l  --icons'
alias ls='eza -1  --icons'
alias ll='eza -la --icons'
alias ld='eza -lD --icons'
alias cat='bat'
alias cd="z"
alias v="/bin/nvim"
alias vi="/bin/nvim"
alias vim="/bin/nvim"
alias emacs="/bin/nvim"
alias nightlight="pkill gammastep; gammastep -O 3000 & disown"
alias nightlight_off="pkill gammastep;"
alias stow.="pushd ~/.dotfiles/; stow -D .; stow .; popd"
alias bgrng='~/Scripts/bgrng.sh'
alias clip="xclip -selection clipboard"
log_time "after aliases"

# Function to create directory and touch a file
mkdir_and_touch() {
  mkdir -pv "$(dirname "$1")"
  touch "$1"
}
alias touch="mkdir_and_touch"
log_time "after mkdir_and_touch function"

# Environment Variables
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"

export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export RUSTFLAGS='-W clippy::pedantic -W clippy::nursery -W clippy::unwrap_used -W clippy::expect_used'

export PATH=$PATH:/home/fib/.cargo/bin
export PATH="$PYENV_ROOT/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

export LANG=en_US.UTF-8
export EDITOR='nvim'
[[ -n $SSH_CONNECTION ]] && export EDITOR='vim'
log_time "after environment variables"

load_pyenv() {
  if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)" >/dev/null 2>&1
    eval "$(pyenv virtualenv-init -)" >/dev/null 2>&1
  fi
}
(load_pyenv &)
log_time "after pyenv initialization"

# Install zinit if not already installed
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  echo "Installing ZDHARMA-CONTINUUM Initiative Plugin Manager (zdharma-continuum/zinit)…"
  mkdir -p "$HOME/.local/share/zinit" && chmod g-rwX "$HOME/.local/share/zinit"
  git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
      echo "Installation successful." || \
      echo "The clone has failed."
fi
log_time "after zinit installation check"

# Initialize zinit
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
log_time "after zinit initialization"

# Load zinit plugins asynchronously
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust \
  zsh-users/zsh-autosuggestions
log_time "after zinit plugins load"

# Initialize zinit completion
zicompinit; zicdreplay
log_time "after zinit completion initialization"

# Load environment variables from .env files if they exist
set -a
[[ -f .env ]] && source ./.env
[[ -f ./.env.development ]] && source ./.env.development
set +a
log_time "after loading .env files"

# Initialize starship prompt
eval "$(starship init zsh)"
log_time "after starship initialization"

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
log_time "after nvm initialization setup"
