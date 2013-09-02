#!/usr/bin/env bash
# Print Spotify now playing for GNU/Linux running in wine.

trim_method="trim" 	# Can be {trim or roll).
max_len=40		# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"


## Check if Spotify is playing and print that song.
spotify_id=$(xwininfo -root -tree | grep '("spotify' | cut -f1 -d'"' | sed 's/ //g')
echo $spotify_id
if [ -n "$spotify_id" ]; then
	np=$(xwininfo -id "$spotify_id" | grep "xwininfo.*Spotify -" | grep -Po "(?<=\"Spotify - ).*(?=\"$)")
	if [ -n "$np" ]; then
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
