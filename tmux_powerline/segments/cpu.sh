#!/usr/bin/env sh
# Prints the CPU usage: user% sys% idle.

if [ "$PLATFORM" == "linux" ] ; then
    cpu_line=$(top -b -n 1 | grep "Cpu(s)" )
    cpu_user=$(echo "$cpu_line" | grep -Po "(\d+(.\d+)?)(?=%?\s?(us(er)?))")
    cpu_system=$(echo "$cpu_line" | grep -Po "(\d+(.\d+)?)(?=%?\s?(sys?))")
    cpu_idle=$(echo "$cpu_line" | grep -Po "(\d+(.\d+)?)(?=%?\s?(id(le)?))")
else
    cpus_line=$(top -e -l 1 | grep "CPU usage:" | sed 's/CPU usage: //')
    cpu_user=$(echo "$cpus_line" | awk '{print $1}'  | sed 's/%//' )
    cpu_system=$(echo "$cpus_line" | awk '{print $3}'| sed 's/%//' )
    cpu_idle=$(echo "$cpus_line" | awk '{print $5}'  | sed 's/%//' )
fi

if [ -n "$cpu_user" ] && [ -n "$cpu_system" ] && [ -n "$cpu_idle" ]; then
    echo "${cpu_user}, ${cpu_system}, ${cpu_idle}" | awk -F', ' '{printf("%5.1f,%5.1f,%5.1f",$1,$2,$3)}'
    exit 0
else
	exit 1
fi
