
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  export SSH_AUTH_SOCK=/run/user/$(id -u)/ssh-agent.socket
fi
