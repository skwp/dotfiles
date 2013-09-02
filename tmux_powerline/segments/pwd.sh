#/usr/bin/env bash
# Print the current working directory (trimmed to max length).
# NOTE The trimming code's stolen from the web. Courtesy to who ever wrote it.

pwdmaxlen=40		# Max output length.

segment_cwd=$(dirname $0)
source "$segment_cwd/../lib.sh"

# Truncate from the right.
#echo $(get_tmux_cwd | sed -e "s|${HOME}|~|" -e 's/^~$/~\//' -e 's/\(.\{40\}\).*$/\1.../')

# Truncate from the left.
tcwd=$(get_tmux_cwd)
trunc_symbol=".."
dir=${tcwd##*/}
pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
ttcwd=${tcwd/#$HOME/\~}
pwdoffset=$(( ${#ttcwd} - pwdmaxlen ))
if [ ${pwdoffset} -gt "0" ]; then
	ttcwd=${ttcwd:$pwdoffset:$pwdmaxlen}
	ttcwd=${trunc_symbol}/${ttcwd#*/}
fi

echo "$ttcwd"

exit 0
