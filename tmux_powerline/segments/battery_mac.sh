#!/usr/bin/env bash

HEART_CONNECTED=♥
HEART_DISCONNECTED=♡

case $(uname -s) in
    "Darwin")
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
                    export extconnect=$value;;
            esac
            if [[ -n $maxcap && -n $curcap && -n $extconnect ]]; then
                if [[ "$curcap" == "$maxcap" ]]; then
                    exit
                fi
                charge=$(( 100 * $curcap / $maxcap ))
                if [[ "$extconnect" == "Yes" ]]; then
                    echo $HEART_CONNECTED "$charge%"
                else
                    if [[ $charge -lt 50 ]]; then
                        echo -n "#[fg=red]"
                    fi
                    echo $HEART_DISCONNECTED "$charge%"
                fi
                break
            fi
        done
esac
