#!/usr/bin/env bash
# LICENSE This code is not under the same license as the rest of the project as it's "stolen". It's cloned from https://github.com/richoH/dotfiles/blob/master/bin/battery and just some modifications are done so it works for my laptop. Check that URL for more recent versions.

#CUTE_BATTERY_INDICATOR="true"

HEART_FULL=♥
HEART_EMPTY=♡
[ -z "$NUM_HEARTS" ] &&
    NUM_HEARTS=5

cutinate()
{
    perc=$1
    inc=$(( 100 / $NUM_HEARTS))


    for i in `seq $NUM_HEARTS`; do
        if [ $perc -lt 100 ]; then
            echo $HEART_EMPTY
        else
            echo $HEART_FULL
        fi
        perc=$(( $perc + $inc ))
    done
}

linux_get_bat ()
{
    bf=$(cat $BAT_FULL)
    bn=$(cat $BAT_NOW)
    echo $(( 100 * $bn / $bf ))
}

freebsd_get_bat ()
{
    echo "$(sysctl -n hw.acpi.battery.life)"

}

# Do with grep and awk unless too hard

# TODO Identify which machine we're on from teh script.

battery_status()
{
case $(uname -s) in
    "Linux")
        BATPATH=/sys/class/power_supply/BAT0
		if [ ! -d $BATPATH ]; then
			BATPATH=/sys/class/power_supply/BAT1
		fi
        STATUS=$BATPATH/status
        BAT_FULL=$BATPATH/charge_full
		if [ ! -r $BAT_FULL ]; then
			BAT_FULL=$BATPATH/energy_full
		fi
        BAT_NOW=$BATPATH/charge_now
		if [ ! -r $BAT_NOW ]; then
			BAT_NOW=$BATPATH/energy_now
		fi

        if [ "$1" = `cat $STATUS` -o "$1" = "" ]; then
            linux_get_bat
        fi
        ;;
    "FreeBSD")
        STATUS=`sysctl -n hw.acpi.battery.state`
        case $1 in
            "Discharging")
                if [ $STATUS -eq 1 ]; then
                    freebsd_get_bat
                fi
                ;;
            "Charging")
                if [ $STATUS -eq 2 ]; then
                    freebsd_get_bat
                fi
                ;;
            "")
                freebsd_get_bat
                ;;
        esac
        ;;
    "Darwin")
        case $1 in
            "Discharging")
                ext="No";;
            "Charging")
                ext="Yes";;
        esac

        ioreg -c AppleSmartBattery -w0 | \
        grep -o '"[^"]*" = [^ ]*' | \
        sed -e 's/= //g' -e 's/"//g' | \
        sort | \
        while read key value; do
            case $key in
                "MaxCapacity")
                    export maxcap=$value;;
                "CurrentCapacity")
                    export curcap=$value;;
                "ExternalConnected")
                    if [ "$ext" != "$value" ]; then
                        exit
                    fi
                ;;
                "FullyCharged")
                    if [ "$value" = "Yes" ]; then
                        exit
                    fi
                ;;
            esac
            if [[ -n "$maxcap" && -n $curcap ]]; then
                echo $(( 100 * $curcap / $maxcap ))
                break
            fi
        done
esac
}

BATTERY_STATUS=`battery_status $1`
[ -z "$BATTERY_STATUS" ] && exit

if [ -n "$CUTE_BATTERY_INDICATOR" ]; then
    echo `cutinate $BATTERY_STATUS`
else
    echo "${HEART_FULL} ${BATTERY_STATUS}%"
    #echo "⛁ ${BATTERY_STATUS}%"
fi

