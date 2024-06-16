paru() {
    command paru --noconfirm "$@"
    command paru -Qqen > ~/packages.txt
}
alias paruclean="sudo pacman -Rsn $(pacman -Qdtq)"

alias brb="clear && figlet BRB | lolcat"

alias  l='eza -l  --icons'
alias ls='eza -1  --icons'
alias ll='eza -la --icons'
alias ld='eza -lD --icons'
alias cat='bat'
eval "$(zoxide init zsh)"
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

mkdir_and_touch() {
  mkdir -pv "$(dirname "$1")"
  touch "$1"
}
alias touch="mkdir_and_touch"


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
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"


export LANG=en_US.UTF-8
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light zdharma-continuum/zinit-annex-as-monitor
zinit light zdharma-continuum/zinit-annex-bin-gem-node
zinit light zdharma-continuum/zinit-annex-patch-dl
zinit light zdharma-continuum/zinit-annex-rust
# zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions
zicompinit; zicdreplay


set -a
if [[ -f .env ]]; then
  source ./.env
fi
if [[ -f ./.env.development ]]; then
  source ./.env.development
fi
set +a

# source /usr/share/nvm/init-nvm.sh

# bun
# [ -s "/home/fib/.bun/_bun" ] && source "/home/fib/.bun/_bun"
# export BUN_INSTALL="$HOME/.bun"
# export PATH="$BUN_INSTALL/bin:$PATH"

eval "$(starship init zsh)"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
