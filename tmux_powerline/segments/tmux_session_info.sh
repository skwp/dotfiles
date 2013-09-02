#!/usr/bin/env sh
# Prints tmux session info.
# Assuems that [ -n "$TMUX"].
tmux display-message -p '#S:#I.#P'

exit 0
