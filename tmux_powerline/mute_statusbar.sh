#!/usr/bin/env bash
# Toggles the visibility of a statusbar side.

# The powerline root directory.
cwd=$(dirname $0)

# Source lib functions.
source "${cwd}/lib.sh"

side="$1"
mute_status "$side"
