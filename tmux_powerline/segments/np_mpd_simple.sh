#!/usr/bin/env bash
# Simple np script for mpd. Works with streams!
# Only tested on OS X... should work the same way on other platforms though.

trim_method="trim" 	# Can be {Trim or roll).
max_len=40		# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

np=$(mpc current 2>&1)
if [ $? -eq 0 ] && [ -n "$np" ]; then
    mpc | grep "paused" > /dev/null
    if [ $? -eq 0 ]; then
        exit 1
    fi

    case "$trim_method" in
        "roll")
        	np=$(roll_stuff "${np}" ${max_len} 2)
        	;;
        "trim")
			np=$(echo "${np}" | cut -c1-"$max_len")
			;;
	esac
    echo "♫ ${np}"
    exit 0
fi

exit 1
