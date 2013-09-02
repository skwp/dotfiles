#!/usr/bin/env bash
# Prints the local network IP address for a staticly defined NIC or search for an IP address on all active NICs.

# TODO fix the mac part so it also can search for interfaces like the Linux one can.
if [ "$PLATFORM" == "mac" ]; then
	nic0="en0"
	nic1="en1"

	# Get wired lan IP.
	lan_ip=$(/sbin/ifconfig $nic0 2>/dev/null | grep 'inet ' | awk '{print $2}')
	# If no wired lan, get wireless lan IP.
	if [ -z "$lan_ip" ]; then
		lan_ip=$(/sbin/ifconfig $nic1 2>/dev/null | grep 'inet ' | awk '{print $2}')
	fi
else
	# Get the names of all attached NICs.
	all_nics=$(ip addr show | cut -d ' ' -f2 | tr -d :)
	all_nics=(${all_nics[@]//lo/})   # Remove lo interface.

	for nic in ${all_nics[@]}; do
		# Parse IP address for the NIC.
		lan_ip=$(ip addr show ${nic} | grep '\<inet\>' | tr -s ' ' | cut -d ' ' -f3)
		# Trim the CIDR suffix.
		lan_ip=${lan_ip%/*}

		[ -n "$lan_ip" ] && break
	done
fi

if [ -n "$lan_ip" ]; then
	echo "ⓛ ${lan_ip}"
	exit 0
else
	exit 1
fi
