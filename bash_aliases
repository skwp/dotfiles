# PS
alias psg="ps aux | grep $1"
alias psr='ps aux | grep ruby'

# Moving around
alias ..='cd ..'
alias cdb='cd -'

# Show human friendly numbers and colors
alias df='df -h'
alias ll='ls -alGh'
alias ls='ls -Gh'
alias du='du -h -d 1'

# show me files matching "ls grep"
alias lsg='ll | grep'

# Alias Editing
alias ae='vi ~/dev/config/bash_aliases' #alias edit
alias ar='. ~/dev/config/bash_aliases'  #alias reload

# Bash Options Editing
alias boe='vi ~/dev/config/bash_options' 
alias bor='. ~/dev/config/bash_options' 


# .bash_profile editing
alias bp='vi ~/.bash_profile'
alias br='. ~/.bash_profile'

# Git Aliases
alias gs='git status'
alias gstsh='git stash'
alias gst='git stash'
alias gsh='git show'
alias gshw='git show'
alias gshow='git show'
alias gi='vi .gitignore'
alias gcm='git ci -m'
alias gcim='git ci -m'
alias gci='git ci'
alias gco='git co'
alias ga='git add -A'
alias gu='git unstage'
alias gm='git merge'
alias gms='git merge --squash'
alias gam='git amend'
alias gr='git rebase'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gbi='git rebase --interactive'
alias gl='git log'
alias glg='git log'
alias glog='git log'
alias co='git co'
alias gf='git fetch'
alias gfch='git fetch'
alias gd='git diff'
alias gb='git b'
alias gdc='git diff --cached'
alias gpub='grb publish'
alias gtr='grb track'
alias gpl='git pull'
alias gps='git push'
alias gpsh='git push'
alias gnb='git nb' # new branch aka checkout -b

# Common bash functions
alias less='less -r'
alias tf='tail -f'
alias l='less'
alias lh='ls -alt | head' # see the last modified files
alias fn="find . -name"
alias screen='TERM=screen screen'

# Zippin
alias gz='tar -zcvf'

# Ruby
alias irb='pry'
alias c='script/console --irb=pry'
alias ms='mongrel_rails start'

# Vim/ctags "mctags = make ctags"
alias mctags='/opt/local/bin/ctags -Rf ./tags *'

alias ka9='killall -9'
alias k9='kill -9'

# This trick makes sudo understand all my aliases
alias sudo='sudo '

# Gem install
alias sgi='sudo gem install --no-ri --no-rdoc'
