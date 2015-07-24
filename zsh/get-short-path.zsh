# function to get the short version of the current path
# requires PWD_LENGTH variable to be set
# defaults to 30, if not set
function get_short_path() {
	HOME_TILDE=~
	LONG_PATH=`pwd`
	if [[ $LONG_PATH == $HOME_TILDE ]]; then
		LONG_PATH="~"
	fi

	# check to see if the prompt path length has been specified
	if [ ! -n "$PWD_LENGTH" ]; then
		export PWD_LENGTH=15
	fi

    if [ ${#LONG_PATH} -gt $PWD_LENGTH ]; then
            echo "...${LONG_PATH: -$PWD_LENGTH}"
    else
            echo $LONG_PATH
    fi
}