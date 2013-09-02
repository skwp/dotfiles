#!/usr/bin/env bash
# Prints now playing in Banshee.

trim_method="trim" 	# Can be {trim or roll).
max_len=40		# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

# Check if banshee is playing and print that song.
banshee_pid=$(pidof banshee)
if [ -n "$banshee_pid" ]; then
    banshee_status=$(banshee --query-current-state 2> /dev/null)
    if [[ "$banshee_status" == "current-state: playing" ]]; then
	np=$(banshee --query-artist --query-title | cut  -d ":" -f2 | sed  -e 's/ *$//g' -e 's/^ *//g'| sed -e ':a;N;$!ba;s/\n/ - /g' )
        case "$trim_method" in
            "roll")
        	np=$(roll_stuff "${np}" ${max_len} ${roll_speed})
        	;;
            "trim")
		np=$(echo "${np}" | cut -c1-"$max_len")
		;;
	esac
	echo "♫ ${np}" | cut -c1-"$max_len"
    fi
fi
