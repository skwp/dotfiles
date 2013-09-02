#!/usr/bin/env bash
# Return the number of new mails in your Gmail(or Gmail App email) inbox
# Supports plain text password or OS X keychain.
# You really shouldn't store your password in clear text. Use the Mac OS X keychain,
# or some other encrypted password management solution that can be accessed from the terminal.
# You may enter your password below, but you do so at your own peril!
# Also, for optimum security, don't use your account password. Enable 2-step verification
# on your Google account, and set up an application-specific password for this script,
# then store that in your keychain.
# See http://support.google.com/accounts/bin/answer.py?hl=en&answer=185833 for more info.
#
# For OSX users : MAKE SURE that you add a key to the keychain in the format as follows
# Keychain Item name : http://<value-you-fill-in-server-variable-below>
# Account name : <username-below>@<server-below>
# Password : Your password ( Once again, try to use 2 step-verification and application-specific password)

username="battery_mac.sh"		# Enter your Gmail username here WITH OUT @gmail.com.( OR @domain )
password=""              		# Leave this empty to get password from keychain.
server="gmail.com"       	# Domain name that will complete your email. For normal GMail users it probably is "gmail.com but can be "foo.tld" for Google Apps users.
interval=5               		# Query interval in minutes .
tmp_file="/tmp/tmux-powerline_gmail_count.txt"  # File to store mail count in.
override=false		# When true a force reloaded will be done.

# Get password from OS X keychain.
mac_keychain_get_pass() {
	result=$(security 2>&1 > /dev/null find-internet-password -ga $1 -s $2)
	if [ $? -eq 0 ]; then
        	password=$(echo $result | sed -e 's/password: \"\(.*\)\"/\1/g') #<<< $result)
        	# unset $result
        	return 0
	fi
	exit 1
}

# Create the cache file if it doesn't exist.
if [ ! -f $tmp_file ]; then
    	touch $tmp_file
    	override=true
fi

# Refresh mail count if the tempfile is older than $interval minutes.
let interval=60*$interval
if [ "$PLATFORM" == "mac" ]; then
  	last_update=$(stat -f "%m" ${tmp_file})
else
  	last_update=$(stat -c "%Y" ${tmp_file})
fi
if [ "$(( $(date +"%s") - ${last_update} ))" -gt "$interval" ] || [ "$override" == true ]; then
    	if [ -z "$password" ]; then # Get password from keychain if it isn't already set.
        	if [ "$PLATFORM" == "mac" ]; then
            		mac_keychain_get_pass "${username}@${server}" $server
        	else
            		echo "Implement your own sexy password fetching mechanism here."
            		exit 1
        	fi
    	fi

    	# Check for wget before proceeding.
    	which wget 2>&1 > /dev/null
    	if [ $? -ne 0 ]; then
        	echo "This script requires wget." 1>&2
        	exit 1
    	fi

    	mail=$(wget -q -O - https://mail.google.com/a/${server}/feed/atom --http-user="${username}@${server}" --http-password="${password}" --no-check-certificate | grep fullcount | sed 's/<[^0-9]*>//g')

    	if [ "$mail" != "" ]; then
        	echo $mail > $tmp_file
    	else
        	exit 1
    	fi
fi

let interval=$interval*60
# echo "$(( $(date +"%s") - $(stat -f %m $tmp_file) ))"
mailcount=$(cat $tmp_file)
echo "✉ $mailcount"
exit 0;
