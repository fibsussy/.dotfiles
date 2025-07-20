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

fish_vi_key_bindings
set -g fish_cursor_default block
set -g fish_cursor_insert block
set -g fish_cursor_replace_one underscore
set -g fish_cursor_replace underscore
set -g fish_cursor_external block
set -g fish_cursor_visual block

# tide configure --auto --style=Rainbow --prompt_colors='16 colors' --show_time=No --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style='One line' --prompt_spacing=Compact --icons='Few icons' --transient=Yes
set -gx tide_left_prompt_items character
set -gx tide_right_prompt_items status vi_mode pwd cmd_duration context git jobs direnv node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig
set -gx tide_left_prompt_suffix ""
set -gx tide_vi_mode_icon_insert ""
set -gx tide_vi_mode_icon_default "Normal"
set -gx tide_vi_mode_icon_replace "Replace"
set -gx tide_vi_mode_icon_visual "Visual"

set -g fish_greeting ""
set -g fish_history_size 50000

bind \ce edit_command_buffer
bind \cs sudo_toggle

function load_environment_files
    for file in ~/.api_keys.env .env .env.dev .env.development
        if test -f $file
            while read -l line
                # Skip empty lines and full-line comments
                if string match -qr '^\s*#' $line || string match -qr '^\s*$' $line
                    continue
                end
                # Remove inline comments and parse KEY=VALUE
                set -l clean_line (string replace -r '\s*#.*$' '' $line | string trim)
                if test -n "$clean_line"
                    set -l key (string split -m 1 '=' $clean_line | head -n 1 | string trim)
                    set -l value (string split -m 1 '=' $clean_line | tail -n 1 | string trim)
                    set -gx $key $value
                end
            end < $file
        end
    end
end
load_environment_files
 

source ~/.config/fish/abbreviations.fish
if test -f .python-version
    pyenv init - fish | source
end
zoxide init fish | source
