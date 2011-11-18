# Load secret stuff that I don't want to share with the world on github :)
if [ -e ~/.secrets ]; then
  . ~/.secrets
fi

# Load git completion
. ~/.dotfiles/git-completion.bash

# My aliases and options
. ~/.dotfiles/bash_aliases
. ~/.dotfiles/bash_options
