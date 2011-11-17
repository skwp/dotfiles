Yan's Excellent Dotfiles!
====

To set these up as your own (careful, don't overwrite your bash_profile unintentionally!):

    git clone git://github.com/skwp/dotfiles ~/.dotfiles

    ln -s ~/.dotfiles/bash_profile ~/.bash_profile
    . ~/.bash_profile

Lots of things I do every day are done with 
two or three character mnemonic aliases. Please 
feel free to edit them:

    ae # alias edit
    ar # alias reload

To use the vim files:

    ln -s ~/.dotfiles/vimrc ~/.vimrc
    ln -s ~/.dotfiles/vim ~/.vim

The .vimrc is well commented and broken up by settings. I encourage you
to take a look and learn some of my handy aliases, or comment them out
if you don't like them, or make your own.

Credits
===
I can't take credit for all of this. The vim files are a combination of
work by tpope, scrooloose, and many hours of scouring blogs, vimscripts,
and other places for the cream of the crop of vim and bash awesomeness.

TODO
===
I started migrating to tpope's pathogen, but only a few plugins are 
currently under vim/bundles. 

For more tips and tricks
===
Follow my blog: [yan http://yanpritzker.com]
