function sudo_toggle
    set -l cmd (commandline)
    if string match -q "sudo *" $cmd
        commandline (string replace -r '^sudo ' '' $cmd)
    else
        commandline "sudo $cmd"
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
alias touch 'mkdir -p (dirname $argv[1]) && command touch $argv[1]'
alias l 'eza -lh --icons=auto'
alias ls 'eza -1 --icons=auto'
alias ll 'eza -lha --icons=auto --sort=name --group-directories-first'
alias ld 'eza -lhD --icons=auto'
alias lt 'eza --icons=auto --tree'

alias cd 'z'
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .3 'cd ../../..'
abbr -a .4 'cd ../../../..'
abbr -a .5 'cd ../../../../..'
alias cat 'bat'
alias bat 'bat --paging never --style=numbers,header-filename'
alias v 'nvim'
abbr -a sc 'systemctl'
abbr -a scu 'systemctl --user'
alias grep 'grep --color=auto'
alias fgrep 'grep -F --color=auto'
alias egrep 'grep -E --color=auto'
alias diff 'diff --color=auto'
alias ip 'ip --color=auto'
alias paruclean 'sudo pacman -Rsn (pacman -Qdtq 2>/dev/null)'
alias less $MANPAGER

abbr -a --position anywhere H -- "--help"
abbr -a --position anywhere L -- "| less"
abbr -a --position anywhere G -- '| grep'
abbr -a --position anywhere W -- '| wc'
abbr -a --position anywhere J -- '| jq'
abbr -a --position anywhere C -- '| tee /dev/tty | perl -pe "chomp if eof" | wl-copy'
abbr -a --position anywhere CC -- '| tee /dev/tty | begin; echo "❯ $ZSH_COMMAND"; perl -pe "chomp if eof"; end | wl-copy'
abbr -a --position anywhere null '/dev/null'
abbr -a --position anywhere 2null '&>/dev/null'
abbr -a --position anywhere 2bg '&>/dev/null & disown'

