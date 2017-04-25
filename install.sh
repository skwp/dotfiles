#!/bin/bash

if [ ! -d "$HOME/.yadr" ]; then
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
      if [ -n "$(command -v yum)" ]; then
        sudo yum remove the-silver-searcher
        sudo yum install -y zsh git curl rake vim ctags tmux the_silver_searcher jq fontconfig
      elif [ -n "$(command -v apt-get)" ]; then
        sudo apt-get install -y zsh git curl rake vim exuberant-ctags tmux silversearcher-ag jq fontconfig
      else
        echo "Unsupported PKG Manger, you need install: zsh git curl vim exuberant-ctags tmux the_silver_searcher/silversearcher-ag jq fontconfig"
      fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Will install dependencies via Homebrew"
    else
        echo "Unsupported OS: $OSTYPE"
        exit
    fi
    echo "Installing YADR for the first time."
    # git clone --depth=1 https://github.com/qianthinking/dotfiles.git "$HOME/.yadr"
    git clone --depth=1 https://github.com/wesson-yi/dotfiles.git "$HOME/.yadr"
    GIT_COMP_VERSION=`git --version | awk '{print $3"\n1.7.11"}' | sort -n | head -n 1`
    echo "git version `git --version`, and $GIT_COMP_VERSION"
    if [[ "$GIT_COMP_VERSION" != "1.7.11" ]]; then
      echo "Set git push.default to matching"
      sed -i 's/upstream/matching/' ~/.yadr/git/gitconfig
    fi
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
      sed -i 's/\(^.*reattach\)/#\1/' ~/.yadr/tmux/tmux.conf
    fi
    cd "$HOME/.yadr"
    [ "$1" = "ask" ] && export ASK="true"
    rake install
else
    echo "YADR is already installed"
fi
