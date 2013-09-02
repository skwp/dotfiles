#!/usr/bin/env bash
# Print the currently used keyboard layout
# This depends on a specifically developed program which prints the group id of
# the currently used layout.
# I developed the simple program myself with some guidance as I was unable to
# find anything already developed.
# Some people might suggest:
# $ setxkbmod -query -v | awk -F "+" '{print $2}'
# this will only work if you have set up XKB with a single layout which is true
# for some.

# This script will print the correct layout even if layout is set per window.
# Exit if platform is not linux as this script is dependant on X11
if [ $PLATFORM != "linux" ]; then
	exit 0
fi

cd "$(dirname $0)"
if [ ! -x "xkb_layout" ]; then
	make clean xkb_layout &>/dev/null
fi

if [ -x ./xkb_layout ]; then
	cur_layout_nbr=$(($(./xkb_layout)+1));
	cur_layout=$(setxkbmap -query | grep layout | sed 's/layout:\s\+//g' | \
		awk -F ',' '{print $'$(echo "$cur_layout_nbr")'}')
	echo "⌨  $cur_layout"
else
	exit 1
fi

