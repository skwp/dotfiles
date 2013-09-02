#!/usr/bin/env bash
# Print a simple line of NP in mpd.
#
# Previously I used something as simple as
#mpc --format "%artist%\n%title%" | grep -Pzo '^(.|\n)*?(?=\[)' | sed ':a;N;$!ba;s/\n/ - /g' | sed 's/\s*-\s$//' | cut -c1-50
# But I decided that I don't want any info about songs if there is nothing playing. Unfortunately I did not find a way of expressing this with mpc (I'm sure there is with idle/idleloop) but I did found a useful library: libmpdclient. I've used version 2.7 when developing my small program. Download the latest version here: http://sourceforge.net/projects/musicpd/files/libmpdclient/

trim_method="trim" 	# Can be {trim or roll).
max_len=40		# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

# Source MPD environment variables (MPD_HOST and MPD_PORT). I refactored out this from ~/.bashrc and source this file there as well. This is not needed if you run your MPD server at localhost, no password and on the standard port.
if [ -f $HOME/.mpd_env ]; then
    source $HOME/.mpd_env
fi

cd "$(dirname $0)"

if [ ! -x "np_mpd" ]; then
    make clean np_mpd &>/dev/null
fi


if [ -x "np_mpd" ]; then
    np=$(./np_mpd)
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
    exit 0
else
    exit 1
fi
