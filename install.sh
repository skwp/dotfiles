#!/bin/sh

if [ ! -d "$HOME/.yadr" ]; then
    echo "Installing Ashok's YADR for the first time"
    git clone --depth=1 https://github.com/rajuashok/dotfiles.git "$HOME/.yadr"
    cd "$HOME/.yadr"
    [ "$1" = "ask" ] && export ASK="true"
    rake install
else
    echo "Ashok's YADR is already installed"
fi
