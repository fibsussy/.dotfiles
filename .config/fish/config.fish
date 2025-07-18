if not status is-interactive
    exit
end

set -gx RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -gx RUSTFLAGS '-W clippy::pedantic -W clippy::nursery -A clippy::unreadable_literal -A clippy::struct_excessive_bools'
set -gx PYENV_ROOT "$HOME/.pyenv"
set -gx PYENV_VIRTUALENV_DISABLE_PROMPT 1
set -gx LANG en_US.UTF-8
set -gx EDITOR nvim
set -gx LESSHISTFILE "$XDG_STATE_HOME/less/history"
set -gx PARALLEL_HOME "$XDG_CONFIG_HOME/parallel"
set -gx WGETRC "$XDG_CONFIG_HOME/wgetrc"
set -gx SCREENRC "$XDG_CONFIG_HOME/screen/screenrc"
set -gx MANPAGER 'nvim -c "Man!" -c "set buftype=nofile modifiable"'
set -Ux SSH_AUTH_SOCK /run/user/(id -u)/ssh-agent.socket

fish_add_path -g $HOME/.cargo/bin $PYENV_ROOT/bin $HOME/.local/bin /usr/local/bin /usr/local/sbin

#tide configure --auto --style=Rainbow --prompt_colors='16 colors' --show_time=No --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style='One line' --prompt_spacing=Compact --icons='Few icons' --transient=Yes
set -U tide_left_prompt_suffix ""
set -U tide_left_prompt_items character
set -U tide_right_prompt_items status vi_mode pwd cmd_duration context git jobs direnv node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig

set -U tide_vi_mode_icon_insert ""
set -U tide_vi_mode_icon_default "Normal"
set -U tide_vi_mode_icon_replace "Replace"
set -U tide_vi_mode_icon_visual "Visual"

set -U fish_greeting ""
set -g fish_history_size 50000

fish_vi_key_bindings
bind \ce edit_command_buffer
bind \cs sudo_toggle

function load_environment_files
    if test -f ~/.api_keys.env
        source ~/.api_keys.env
    end
    if test -f .env
        source .env
    end
    if test -f .env.dev
        source .env.dev
    end
    if test -f .env.development
        source .env.development
    end
end


function tmux
    if test (count $argv) -eq 0
        tmux_force
    else
        command tmux $argv
    end
end

function tmux_force --description 'Force tmux session'
    if not command -v tmux >/dev/null
        echo -e "\033[31mError: tmux is not installed.\033[0m" >&2
        return 1
    end
    if set -q TMUX
        echo -e "\033[31mError: Already in a tmux session.\033[0m" >&2
        return 1
    end
    if tmux has-session -t '~' 2>/dev/null
        if not tmux attach-session -t '~' 2>/dev/null
            echo -e "\033[31mError: Failed to attach to tmux session '~'.\033[0m" >&2
            return 1
        end
    else
        if not tmux new-session -s '~' -c '~' 2>/dev/null
            echo -e "\033[31mError: Failed to create new tmux session '~'.\033[0m" >&2
            return 1
        end
    end
    while tmux has-session 2>/dev/null
        if not tmux attach 2>/dev/null
            echo -e "\033[31mError: Failed to reattach to tmux.\033[0m" >&2
            return 1
        end
    end
    return 0
end

function sudo_toggle
    set -l cmd (commandline)
    if string match -q "sudo *" $cmd
        commandline (string replace -r '^sudo ' '' $cmd)
    else
        commandline "sudo $cmd"
    end
end

function paru
    if command -v paru >/dev/null
        command paru --noconfirm $argv
        command paru -Qqen > ~/packages.txt 2>/dev/null
    else
        echo "paru is not installed"
        return 1
    end
end

function download
    if string match -r '^https?://(www\.)?(youtube\.com|youtu\.be)/' $argv[1] >/dev/null
        if command -v yt-dlp >/dev/null
            yt-dlp $argv
        else
            echo "yt-dlp is not installed"
            return 1
        end
    else
        if command -v gallery-dl >/dev/null
            gallery-dl -D . --cookies-from-browser firefox $argv
        else
            echo "gallery-dl is not installed"
            return 1
        end
    end
end

function stow_dotfiles
    if command -v stow >/dev/null
        set trapped_dir (pwd)
        cd ~/.dotfiles/ 2>/dev/null || begin; echo "~/.dotfiles directory not found"; return 1; end
        stow -D .
        stow . --adopt
        cd $trapped_dir
    else
        echo "stow is not installed"
        return 1
    end
end

function last_history_item; echo $history[1]; end
abbr -a !! --position anywhere --function last_history_item

alias brb 'clear; figlet BRB | lolcat'
alias fastfetch '~/.config/fastfetch/fastfetch_inline.sh'

abbr -a rm 'rm -i'
abbr -a tm 'trash'
abbr -a cd 'z'
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .3 'cd ../../..'
abbr -a .4 'cd ../../../..'
abbr -a .5 'cd ../../../../..'
abbr -a mkdir 'mkdir -pv'
abbr -a l 'eza -lh --icons=auto'
abbr -a ls 'eza -1 --icons=auto'
abbr -a ll 'eza -lha --icons=auto --sort=name --group-directories-first'
abbr -a ld 'eza -lhD --icons=auto'
abbr -a lt 'eza --icons=auto --tree'
abbr -a cat 'bat'
abbr -a v 'nvim'
abbr -a sc 'systemctl'
abbr -a scu 'systemctl --user'
abbr -a grep 'grep --color=auto'
abbr -a fgrep 'grep -F --color=auto'
abbr -a egrep 'grep -E --color=auto'
abbr -a diff 'diff --color=auto'
abbr -a ip 'ip --color=auto'
abbr -a touch 'mkdir -p (dirname $argv[1]) && command touch $argv[1]'
abbr -a paruclean 'sudo pacman -Rsn (pacman -Qdtq 2>/dev/null)'

abbr -a --position anywhere H -- "--help"
abbr -a --position anywhere L -- "| $MANPAGER"
abbr -a --position anywhere G -- '| grep'
abbr -a --position anywhere W -- '| wc'
abbr -a --position anywhere J -- '| jq'
abbr -a --position anywhere C -- '| tee /dev/tty | perl -pe "chomp if eof" | wl-copy'
abbr -a --position anywhere CC -- '| tee /dev/tty | begin; echo "❯ $ZSH_COMMAND"; perl -pe "chomp if eof"; end | wl-copy'
abbr -a --position anywhere null '/dev/null'
abbr -a --position anywhere 2null '&>/dev/null'
abbr -a --position anywhere 2bg '&>/dev/null & disown'

zoxide init fish | source
