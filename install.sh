#!/bin/sh

VIM=$(which vim)
RAKE=$(which rake)
BUNDLER=$(which bundle)
ZSH=$(which zsh)

fail () {
  # Print an error message and exit.

  tput setaf 1 ; echo "Error: ${1}" ; tput sgr0
  exit 1
}

sanity_check () {
  # Make sure required programs are installed and can be executed.

  if [[ -z ${VIM} && ! -x ${VIM} ]]; then
    fail "vim is not available"
  fi

  if [[ -z ${RAKE} && ! -x ${RAKE} ]]; then
    fail "rake is not available"
  fi

  if [[ -z ${BUNDLER} && ! -x ${BUNDLER} ]]; then
    fail "bundler is not available"
  fi

  if [[ -z ${ZSH} && ! -x ${ZSH} ]]; then
    fail "zsh is not available"
  fi
}

sanity_check

if [ ! -d "$HOME/.yadr" ]; then
    echo "Installing YADR for the first time"
    git clone https://github.com/skwp/dotfiles.git "$HOME/.yadr"
    cd "$HOME/.yadr"
    [ "$1" = "ask" ] && export ASK="true"
    rake install
else
    echo "YADR is already installed"
fi
