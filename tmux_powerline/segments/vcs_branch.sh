#!/usr/bin/env bash
# Prints current branch in a VCS directory if it could be detected.

# Source lib to get the function get_tmux_pwd
segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

tmux_path=$(get_tmux_cwd)
cd "$tmux_path"

branch_symbol="⭠"
git_colour="colour5"
git_svn_colour="colour34"
svn_colour="colour220"
hg_colour="colour45"

# Show git banch.
parse_git_branch() {
	type git >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	#git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \[\1\]/'

	# Quit if this is not a Git repo.
    branch=$(git symbolic-ref HEAD 2> /dev/null)
    if [[ -z $branch ]] ; then
        # attempt to get short-sha-name
        branch=":$(git rev-parse --short HEAD 2> /dev/null)"
    fi
	if [ "$?" -ne 0 ]; then
        # this must not be a git repo
		return
	fi

    # clean off unnecessary information
    branch=${branch##*/}

    echo "$(git branch --no-color 2>/dev/null)" | grep "remotes/git-svn" &>/dev/null
	is_gitsvn=$([ "$?" -eq 0 ] && echo 1 || echo 0)

	echo  -n "#[fg="
	if [ "$is_gitsvn" -eq "0" ]; then
		echo -n "$git_colour"
	else
		echo -n "$git_svn_colour"
	fi
	# TODO pass colour arguments as paramters/globals to segments?
	echo "]${branch_symbol} #[fg=${git_colour}]${branch}"
}

# Show SVN branch.
parse_svn_branch() {
	type svn >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	if [ ! -d ".svn/" ]; then
		return
	fi


	local svn_root=$(svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p')
	local svn_url=$(svn info 2>/dev/null | sed -ne 's#^URL: ##p')

	local branch=$(echo $svn_url | sed -e 's#^'"${svn_root}"'##g' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$' | awk '{print $1}')
	echo  "#[fg=${svn_colour}]${branch_symbol} #[fg=colour5]${branch}"
}

parse_hg_branch() {
	type hg >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	summary=$(hg summary)
	if [ "$?" -ne 0 ]; then
		return
	fi

	local branch=$(echo "$summary" | grep 'branch:' | cut -d ' ' -f2)
	echo  "#[fg=${hg_colour}]${branch_symbol} #[fg=colour42]${branch}"
}

branch=""
if [ -n "${git_branch=$(parse_git_branch)}" ]; then
	branch="$git_branch"
elif [ -n "${svn_branch=$(parse_svn_branch)}" ]; then
	branch="$svn_branch"
elif [ -n "${hg_branch=$(parse_hg_branch)}" ]; then
	branch="$hg_branch"
fi

if [ -n "$branch" ]; then
	echo "${branch}"
fi
