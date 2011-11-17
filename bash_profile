# Load secret stuff that I don't want to share with the world on github :)
if [ -e ~/.secrets ]; then
  . ~/.secrets
fi

# Load git completion
. ~/dev/bin/git-completion.bash

# My aliases and options
. ~/dev/config/bash_aliases
. ~/dev/config/bash_options
