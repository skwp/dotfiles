#!/usr/bin/env bash
# This checks if the current branch is ahead of
# or behind the remote branch with which it is tracked

# Source lib to get the function get_tmux_pwd
segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

tmux_path=$(get_tmux_cwd)
cd "$tmux_path"

flat_symbol="⤚"
git_colour="colour5"
git_svn_colour="colour34"
svn_colour="colour220"
hg_colour="colour45"

parse_git_stats(){
	type git >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

    # check if git
    [[ -z $(git rev-parse --git-dir 2> /dev/null) ]] && return

    refs=$(git symbolic-ref HEAD 2> /dev/null)
    branch=${refs##*/}
    if [[ -z $branch ]] ; then
        branch=$(git rev-parse --short HEAD)
    fi

    # look up this branch in the configuration
    remote=$(git config branch.$branch.remote)
    remote_ref=$(git config branch.$branch.merge)

    # if this branch is not connected to a remote
    [[ -z $remote ]] && return

    # convert the remote ref into the tracking ref... this is a hack
    remote_branch=$(expr $remote_ref : 'refs/heads/\(.*\)')
    tracking_branch=refs/remotes/$remote/$remote_branch

    # make a list of behind/ahead left/right sha's
    tmpLR=/tmp/$(basename $0).left-right
    git rev-list --left-right $tracking_branch...HEAD &> $tmpLR

    numAhead=$(grep ">" $tmpLR | wc -l)
    numBehind=$(grep "<" $tmpLR | wc -l)

    # print out the information
    if [[ $numBehind -gt 0 ]] ; then
        local ret="↓ $numBehind"
    fi
    if [[ $numAhead -gt 0 ]] ; then
        local ret="${ret}↑ $numAhead"
    fi
    echo $ret
}
parse_hg_stats(){
	type svn >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi
    # not yet implemented
}
parse_svn_stats(){
	type hg >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi
    # not yet implemented
}

stats=""
if [ -n "${git_stats=$(parse_git_stats)}" ]; then
    stats="$git_stats"
elif [ -n "${svn_stats=$(parse_svn_stats)}" ]; then
    stats="$svn_stats"
elif [ -n "${hg_stats=$(parse_hg_stats)}" ]; then
    stats="$hg_stats"
fi

if [ -n "$stats" ]; then
    echo "${stats}"
fi
