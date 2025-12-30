if [[ -z "$SSH_AUTH_SOCK" ]]; then
  export SSH_AUTH_SOCK=/run/user/$(id -u)/ssh-agent.socket
fi

# Source cargo environment if it exists
if [[ -f "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi

return 0
