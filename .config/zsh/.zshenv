# Source cargo environment if it exists
if [[ -f "$CARGO_HOME/env" ]]; then
  . "$CARGO_HOME/env"
fi

export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$UID}/ssh-agent.socket"

return 0
