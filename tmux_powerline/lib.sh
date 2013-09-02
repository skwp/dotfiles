# Library functions.

segments_dir="segments"
declare entries

if [ -n "$USE_PATCHED_FONT" -a "$USE_PATCHED_FONT" == "true" ]; then
    # Separators (patched font required)
    separator_left_bold="⮂"
    separator_left_thin="⮃"
    separator_right_bold="⮀"
    separator_right_thin="⮁"
else
    # Alternative separators in the normal Unicode table.
    separator_left_bold="◀"
    separator_left_thin="❮"
    separator_right_bold="▶"
    separator_right_thin="❯"
fi

# Make sure that grep does not emit colors.
export GREP_OPTIONS="--color=never"

# Create temp directory for segments to use.
export tp_tmpdir="/tmp/tmux-powerline"
if [ ! -d "$tp_tmpdir" ]; then
    mkdir "$tp_tmpdir"
fi

# Register a segment.
register_segment() {
    segment_name="$1"
    entries[${#entries[*]}]="$segment_name"

}

print_status_line_right() {
    local prev_bg="colour235"
    for entry in ${entries[*]}; do
    local script=$(eval echo \${${entry}["script"]})
    local foreground=$(eval echo \${${entry}["foreground"]})
    local background=$(eval echo \${${entry}["background"]})
    local separator=$(eval echo \${${entry}["separator"]})
    local separator_fg=""
    if [ $(eval echo \${${entry}["separator_fg"]+_}) ];then
        separator_fg=$(eval echo \${${entry}["separator_fg"]})
    fi

    # Can't be declared local if we want the exit code.
    output=$(${script})
    local exit_code="$?"
  if [ "$DEBUG_MODE" != "false" ]; then
      if [ "$exit_code" -ne 0 ]; then
            echo "Segment ${script} exited with code ${exit_code}. Aborting."
            exit 1
        elif [ -z "$output" ]; then
          continue
        fi
  fi
    __ui_right "$prev_bg" "$background" "$foreground" "$separator" "$separator_fg"
    echo -n "$output"
    unset output
    prev_bg="$background"
    done
    # End in a clean state.
    echo "#[default]"
}

first_segment_left=1
print_status_line_left() {
    prev_bg="colour148"
    for entry in ${entries[*]}; do
    local script=$(eval echo \${${entry}["script"]})
    local foreground=$(eval echo \${${entry}["foreground"]})
    local background=$(eval echo \${${entry}["background"]})
    local separator=$(eval echo \${${entry}["separator"]})
    local separator_fg=""
    if [ $(eval echo \${${entry}["separator_fg"]+_}) ];then
        separator_fg=$(eval echo \${${entry}["separator_fg"]})
    fi

    local output=$(${script})
    if [ -n "$output" ]; then
            __ui_left "$prev_bg" "$background" "$foreground" "$separator" "$separator_fg"
            echo -n "$output"
            prev_bg="$background"
            if [ "$first_segment_left" -eq "1" ]; then
                first_segment_left=0
            fi
        fi
    done
    __ui_left "colour235" "colour235" "red" "$separator_right_bold" "$prev_bg"

    # End in a clean state.
    echo "#[default]"
}

#Internal printer for right.
__ui_right() {
    local bg_left="$1"
    local bg_right="$2"
    local fg_right="$3"
    local separator="$4"
    local separator_fg
    if [ -n "$5" ]; then
    separator_fg="$5"
    else
    separator_fg="$bg_right"
    fi
    echo -n " #[fg=${separator_fg}, bg=${bg_left}]${separator}#[fg=${fg_right},bg=${bg_right}] "
}

# Internal printer for left.
__ui_left() {
    local bg_left="$1"
    local bg_right="$2"
    local fg_right="$3"
    local separator
    if [ "$first_segment_left" -eq "1" ]; then
    separator=""
    else
    separator="$4"
    fi

    local separator_bg
    if [ -n "$5" ]; then
    bg_left="$5"
    separator_bg="$bg_right"
    else
    separator_bg="$bg_right"
    fi

    if [ "$first_segment_left" -eq "1" ]; then
    echo -n "#[bg=${bg_right}]"
    fi

    echo -n " #[fg=${bg_left}, bg=${separator_bg}]${separator}#[fg=${fg_right},bg=${bg_right}]"

    if [ "$first_segment_left" -ne "1" ]; then
    echo -n " "
    fi
}

# Get the current path in the segment.
get_tmux_cwd() {
    local env_name=$(tmux display -p "TMUXPWD_#I_#P")
    local env_val=$(tmux show-environment | grep "$env_name")
    # The version below is still quite new for tmux. Uncommented this in the future :-)
    #local env_val=$(tmux show-environment "$env_name" 2>&1)

    if [[ ! $env_val =~ "unknown variable" ]]; then
    local tmux_pwd=$(echo "$env_val" | sed 's/^.*=//')
    echo "$tmux_pwd"
    fi
}

# Exit this script if a mute file exists.
mute_status_check() {
    local side="$1"
    local tmux_session=$(tmux display -p "#S")
    local mute_file="${tp_tmpdir}/mute_${tmux_session}_${side}"
    if [ -e  "$mute_file" ]; then
    exit
    fi
}

# Toggles the visibility of a statusbar side.
mute_status() {
    local side="$1"
    local tmux_session=$(tmux display -p "#S")
    local mute_file="${tp_tmpdir}/mute_${tmux_session}_${side}"
    if [ -e  "$mute_file" ]; then
    rm "$mute_file"
    else
    touch "$mute_file"
    fi
}

# Rolling anything what you want.
# arg1: text to roll.
# arg2: max length to display.
# arg3: roll speed in characters per second.
roll_stuff() {
    local stuff="$1"    # Text to print
    if [ -z "$stuff" ]; then
        return;
    fi
    local max_len="10"  # Default max length.
    if [ -n "$2" ]; then
        max_len="$2"
    fi
    local speed="1" # Default roll speed in chars per second.
    if [ -n "$3" ]; then
        speed="$3"
    fi
    # Anything starting with 0 is an Octal number in Shell,C or Perl,
    # so we must explicityly state the base of a number using base#number
    local offset=$((10#$(date +%s) * ${speed} % ${#stuff}))
    # Truncate stuff.
    stuff=${stuff:offset}
    local char  # Character.
    local bytes # The bytes of one character.
    local index
    for ((index=0; index < max_len; index++)); do
        char=${stuff:index:1}
        bytes=$(echo -n $char | wc -c)
        # The character will takes twice space
        # of an alphabet if (bytes > 1).
        if ((bytes > 1)); then
            max_len=$((max_len - 1))
        fi
    done
    stuff=${stuff:0:max_len}
    #echo "index=${index} max=${max_len} len=${#stuff}"
    # How many spaces we need to fill to keep
    # the length of stuff that will be shown?
    local fill_count=$((${index} - ${#stuff}))
    for ((index=0; index < fill_count; index++)); do
        stuff="${stuff} "
    done
    echo "${stuff}"
}