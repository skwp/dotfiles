#!/usr/bin/env bash
# Prints the current weather in Celsius, Fahrenheits or lord Kelvins. The forecast is cached and updated with a period of $update_period.

# You location. Find a code that works for you:
# 1. Go to Yahoo weather http://weather.yahoo.com/
# 2. Find the weather for you location
# 3. Copy the last numbers in that URL. e.g. "http://weather.yahoo.com/united-states/california/newport-beach-12796587/" has the number "12796587"
location="20066118"

# Can be any of {c,f,k}.
unit="c"

# The update period in seconds.
update_period=600

# Cache file.
tmp_file="${tp_tmpdir}/weather_yahoo.txt"

# Get symbol for condition. Available conditions: http://developer.yahoo.com/weather/#codes
get_condition_symbol() {
    local condition=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$condition" in
    "sunny" | "hot")
        hour=$(date +%H)
        if [ "$hour" -ge "22" -o "$hour" -le "5" ]; then
            #echo "☽"
            echo "☾"
        else
            #echo "☀"
            echo "☼"
        fi
        ;;
    "rain" | "mixed rain and snow" | "mixed rain and sleet" | "freezing drizzle" | "drizzle" | "freezing rain" | "showers" | "mixed rain and hail" | "scattered showers" | "isolated thundershowers" | "thundershowers")
            #echo "☂"
            echo "☔"
        ;;
    "snow" | "mixed snow and sleet" | "snow flurries" | "light snow showers" | "blowing snow" | "sleet" | "hail" | "heavy snow" | "scattered snow showers" | "snow showers")
            #echo "☃"
            echo "❅"
        ;;
    "cloudy" | "mostly cloudy" | "partly cloudy")
        echo "☁"
        ;;
    "tornado" | "tropical storm" | "hurricane" | "severe thunderstorms" | "thunderstorms" | "isolated thunderstorms" | "scattered thunderstorms")
            #echo "⚡"
            echo "☈"
        ;;
    "dust" | "foggy" | "haze" | "smoky" | "blustery" | "mist")
        #echo "♨"
        #echo "﹌"
        echo "〰"
        ;;
    "windy")
        #echo "⚐"
        echo "⚑"
        ;;
    "clear" | "fair" | "cold")
        #echo "✈"    # So clear you can see the aeroplanes!
        echo "〇"
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
    degree="${lines[0]}"
    condition="${lines[1]}"
}

degree=""
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

if [ -z "$degree" ]; then
    weather_data=$(curl --max-time 4 -s "http://weather.yahooapis.com/forecastrss?w=${location}&u=${unit}")
    if [ "$?" -eq "0" ]; then
        error=$(echo "$weather_data" | grep "problem_cause\|DOCTYPE");
        if [ -n "$error" ]; then
            echo "error"
            exit 1
        fi
# <yweather:units temperature="F" distance="mi" pressure="in" speed="mph"/>
    unit=$(echo "$weather_data" | grep -PZo "<yweather:units [^<>]*/>" | sed 's/.*temperature="\([^"]*\)".*/\1/')
    condition=$(echo "$weather_data" | grep -PZo "<yweather:condition [^<>]*/>")
# <yweather:condition  text="Clear"  code="31"  temp="66"  date="Mon, 01 Oct 2012 8:00 pm CST" />
    degree=$(echo "$condition" | sed 's/.*temp="\([^"]*\)".*/\1/')
    condition=$(echo "$condition" | sed 's/.*text="\([^"]*\)".*/\1/')
        echo "$degree" > $tmp_file
        echo "$condition" >> $tmp_file
    elif [ -f "$tmp_file" ]; then
        read_tmp_file
    fi
fi

if [ -n "$degree" ]; then
    if [ "$unit" == "k" ]; then
        degree=$(echo "${degree} + 273.15" | bc)
    fi
    unit_upper=$(echo "$unit" | tr '[cfk]' '[CFK]')
    condition_symbol=$(get_condition_symbol "$condition")
    echo "${condition_symbol} ${degree}°${unit_upper}"
fi
