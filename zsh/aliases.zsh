# Aliases in this file are bash and zsh compatible

# Don't change. The following determines where YADR is installed.
yadr=$HOME/.yadr

# YADR support
# alias yav='yadr vim-add-plugin'
# alias ydv='yadr vim-delete-plugin'
# alias ylv='yadr vim-list-plugin'
# alias yup='yadr update-plugins'
# alias yip='yadr init-plugins'

# PS
alias psa="ps aux"
alias psg="ps aux | grep "
alias psr='ps aux | grep ruby'

# Moving around
# alias cdb='cd -'

# Show human friendly numbers and colors
alias df='df -h'
alias ll='ls -alGh'
alias ls='ls -Gh'
alias du='du -h -d 2'
alias free='free -m'

# show me files matching "ls grep"
# alias lsg='ll | grep'

# Alias Editing
# alias ae='vim $yadr/zsh/aliases.zsh' #alias edit
# alias ar='source $yadr/zsh/aliases.zsh'  #alias reload

# vimrc editing
alias ve='vim ~/.vimrc'

# zsh profile editing
alias ze='vim ~/.zshrc'
alias zr='source ~/.zshrc'

# Git Aliases
alias gs='git status'
alias gst='git status'
alias gsa='git stash apply'
alias gsh='git show'
alias gcm='git ci -m'
alias gcim='git ci -m'
alias gci='git ci'
alias gco='git co'
alias gcp='git cp'
alias ga='git add -A'
alias guns='git unstage'
alias gm='git merge'
alias gl='git l'
alias gf='git fetch'
alias gd='git diff'
alias gb='git b'
alias gpl='git pull'
alias gps='git push'
alias grs='git reset'
alias gt='git t'

# Common shell functions
alias less='less -r'
alias tf='tail -f'
alias l='less'
alias lh='ls -alt | head' # see the last modified files
alias c='clear'

# Zippin
alias gz='tar -zcvf'

# Ruby
alias be='bundle exec'
alias rc='rails c'
alias rs='rails s'
alias rg='rails g'
alias tfdl='tail -f log/development.log'
alias ka9='killall -9'
alias k9='kill -9'

# Rust
alias cb='cargo build'
alias cr='cargo run'

# Node
alias grunt='node_modules/.bin/grunt'
alias gulp='node_modules/.bin/gulp'

# TODOS
# This uses NValt (NotationalVelocity alt fork) - http://brettterpstra.com/project/nvalt/
# to find the note called 'todo'
alias todo='open nvalt://find/todo'

alias rdm='rake db:migrate'
alias rdr='rake db:reset'

# Sprintly - https://github.com/nextbigsoundinc/Sprintly-GitHub
# alias sp='sprintly'
# spb = sprintly branch - create a branch automatically based on the bug you're working on
# alias spb="git checkout -b \`sp | tail -2 | grep '#' | sed 's/^ //' | sed 's/[^A-Za-z0-9 ]//g' | sed 's/ /-/g' | cut -d"-" -f1,2,3,4,5\`"
