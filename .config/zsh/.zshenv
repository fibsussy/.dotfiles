# Source cargo environment if it exists
if [[ -f "$CARGO_HOME/env" ]]; then
  . "$CARGO_HOME/env"
fi

return 0
