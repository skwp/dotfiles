#!/usr/bin/env sh
# Prints the uptime.
uptime | grep -PZo "(?<=up )[^,]*"
