#!/bin/bash
# Prints the current weather in Celsius, Fahrenheits or lord Kelvins. The forecast is cached and updated with a period of $update_period.
# NOTE this has stoppned working, sadly.

# You location. Find a string that works for you by Googling on "weather in <location-string>"
location="Braunschweig, Deutschland"

# Can be any of {c,f,k}.
unit="c"

# Update time in seconds.
update_period=600

# Cach file.
tmp_file="${tp_tmpdir}/weather_google.txt"

get_condition_symbol() {
	local conditions=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	case "$conditions" in
	sunny | "partly sunny" | "mostly sunny")
		hour=$(date +%H)
		if [ "$hour" -ge "22" -o "$hour" -le "5" ]; then
			#echo "☽"
			echo "☾"
		else
			#echo "☀"
			echo "☼"
		fi
		;;
	"rain and snow" | "chance of rain" | "light rain" | rain | "heavy rain" | "freezing drizzle" | flurries | showers | "scattered showers" | drizzle | "rain showers")
		#echo "☂"
		echo "☔"
		;;
	snow | "light snow" | "scattered snow showers" | icy | ice/snow | "chance of snow" | "snow showers" | sleet)
		#echo "☃"
		echo "❅"
		;;
	"partly cloudy" | "mostly cloudy" | cloudy | overcast)
		echo "☁"
		;;
	"chance of storm" | thunderstorm | "chance of tstorm" | storm | "scattered thunderstorms")
		#echo "⚡"
		echo "☈"
		;;
	dust | fog | smoke | haze | mist)
		echo "♨"
		;;
	windy)
		echo "⚑"
		#echo "⚐"
		;;
	clear)
		#echo "☐"
		echo "✈"	# So clear you can see the aeroplanes! TODO what symbol does best represent a clear sky?
		;;
	*)
		echo "？"
		;;
	esac
}

read_tmp_file() {
	if [ ! -f "$tmp_file" ]; then
		return
	fi
	IFS_bak="$IFS"
	IFS=$'\n'
	lines=($(cat ${tmp_file}))
	IFS="$IFS_bak"
	degrees="${lines[0]}"
	conditions="${lines[1]}"
}

degrees=""
if [ -f "$tmp_file" ]; then
	if [ "$PLATFORM" == "mac" ]; then
		last_update=$(stat -f "%m" ${tmp_file})
	else
		last_update=$(stat -c "%Y" ${tmp_file})
	fi
	time_now=$(date +%s)

	up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)
	if [ "$up_to_date" -eq 1 ]; then
		read_tmp_file
	fi
fi

if [ -z "$degrees" ]; then
	if [ "$unit" == "k" ]; then
		search_unit="c"
	else
		search_unit="$unit"
	fi
	# Convert spaces before using this in the URL.
	if [ "$PLATFORM" == "mac" ]; then
		search_location=$(echo "$location" | sed -e 's/[ ]/%20/g')
	else
		search_location=$(echo "$location" | sed -e 's/\s/%20/g')
	fi

	weather_data=$(curl --max-time 4 -s "http://www.google.com/ig/api?weather=${search_location}")
	if [ "$?" -eq "0" ]; then
		error=$(echo "$weather_data" | grep "problem_cause\|DOCTYPE");
		if [ -n "$error" ]; then
			echo "error"
			exit 1
		fi
		degrees=$(echo "$weather_data" | sed "s|.*<temp_${search_unit} data=\"\([^\"]*\)\"/>.*|\1|")
		if [ "$PLATFORM" == "mac" ]; then
			conditions=$(echo $weather_data | xpath //current_conditions/condition/@data 2> /dev/null | grep -oe '".*"' | sed "s/\"//g")
		else
			conditions=$(echo "$weather_data" | grep -PZo "<current_conditions>(\\n|.)*</current_conditions>" | grep -PZo "(?<=<condition\sdata=\")([^\"]*)")
		fi
		echo "$degrees" > $tmp_file
		echo "$conditions" >> $tmp_file
	elif [ -f "$tmp_file" ]; then
		read_tmp_file
	fi
fi

if [ -n "$degrees" ]; then
	if [ "$unit" == "k" ]; then
		degrees=$(echo "${degrees} + 273.15" | bc)
	fi
	unit_upper=$(echo "$unit" | tr '[cfk]' '[CFK]')
	condition_symbol=$(get_condition_symbol "$conditions")
	echo "${condition_symbol} ${degrees}°${unit_upper}"
fi
