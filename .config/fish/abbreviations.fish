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
alias touch 'mkdir -p (dirname $argv[1]) && command touch $argv[1]'

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
alias bat 'bat --paging never --style=numbers,header-filename'
abbr -a v 'nvim'
abbr -a sc 'systemctl'
abbr -a scu 'systemctl --user'
abbr -a grep 'grep --color=auto'
abbr -a fgrep 'grep -F --color=auto'
abbr -a egrep 'grep -E --color=auto'
abbr -a diff 'diff --color=auto'
abbr -a ip 'ip --color=auto'
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

