#!/usr/bin/env bash
# Prints now playing in Rhytmbox.

trim_method="trim" 	# Can be {trim or roll).
max_len=40		# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

# Check if rhythmbox is playing and print that song.
rhythmbox_pid=$(pidof rhythmbox)
if [ -n "$rhythmbox_pid" ]; then
	np=$(rhythmbox-client --no-start --print-playing)	# Does not tell if the music is playing or paused.
	rhythmbox_paused=$(xwininfo -root -tree | grep "$np" | sed "s/${np}//;s/ //g" | cut -f2 -d '"')
	# TODO I cant produce the output "Not playing", using rhythmbox 2.97.
	#STATUS=$(rhythmbox-client --no-start --print-playing)
	if [[ "$rhythmbox_paused" != "(Paused)" ]]; then
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
