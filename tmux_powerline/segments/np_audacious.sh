#!/usr/bin/env bash
# Print Audacious now playing.

trim_method="trim" 	# Can be {trim or roll).
max_len=40		# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

# Check if audacious is playing and print that song.
audacious_pid=$(pidof audacious)
if [ -n "$audacious_pid" ]; then
    if $(audtool playback-playing); then
        np=$(audtool current-song)
        case "$trim_method" in
            "roll")
        	np=$(roll_stuff "${np}" ${max_len} ${roll_speed})
        	;;
            "trim")
		np=$(echo "${np}" | cut -c1-"$max_len")
		;;
	esac
	echo "♫ ${np}"
    fi
fi
