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

# tide configure --auto --style=Rainbow --prompt_colors='16 colors' --show_time=No --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style='One line' --prompt_spacing=Compact --icons='Few icons' --transient=Yes
set -g tide_left_prompt_items pwd character
set -g tide_right_prompt_items status vi_mode pwd cmd_duration context git jobs direnv node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig
set -g tide_left_prompt_suffix
set -g tide_vi_mode_icon_insert
set -g tide_vi_mode_icon_default Normal
set -g tide_vi_mode_icon_replace Replace
set -g tide_vi_mode_icon_visual Visual

set -g fish_greeting ""
set -g fish_history_size 50000

fish_vi_key_bindings
set -g fish_cursor_default block
set -g fish_cursor_insert block
set -g fish_cursor_replace_one underscore
set -g fish_cursor_replace underscore
set -g fish_cursor_external block
set -g fish_cursor_visual block

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


source ~/.config/fish/abbreviations.fish

zoxide init fish | source
