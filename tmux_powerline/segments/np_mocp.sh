#!/usr/bin/env bash
# Prints now playing in Mocp. If the output is too long it will scroll like a marquee tag.

trim_method="roll" 	# Can be {trim or roll).
max_len=20		# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

# Check if rhythmbox is playing and print that song.
mocp_pid=$(pidof mocp)
if [ -n "$mocp_pid" ]; then
    np=$(mocp -i | grep ^Title | sed "s/^Title://")
    mocp_paused=$(mocp -i | grep ^State | sed "s/^State: //")
    if [[ $np ]]; then
        case "$trim_method" in
            "roll")
        	np=$(roll_stuff "${np}" ${max_len} ${roll_speed})
        	;;
            "trim")
		np=$(echo "${np}" | cut -c1-"$max_len")
		;;
	esac
        if [[ "$mocp_paused" != "PAUSE" ]]; then
            echo "♫ ⮀ ${np}"
        elif [[ "$mocp_paused" == "PAUSE" ]]; then
            echo "♫ || ${np}"
        fi
    fi
fi
