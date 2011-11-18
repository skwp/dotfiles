Yan's Excellent Dotfiles!
====

There are two main goals accomplished in my dotfiles to produce insane productivity

  * All common bash commands should be two and three character mnemonic aliases
  * Most vim tasks, especially those having to do with navigation, should be mapped to a single Capital Letter or two letter mnemonic. 

Submodules
---

This project uses git submodules for some of its plugins. Please run:

    git submodule update

To get all the current plugins. Over time, I plan to move all plugins into submodules.

Setup for Bash
---
To set these up as your own (careful, don't overwrite your bash_profile unintentionally!):

    git clone git://github.com/skwp/dotfiles ~/.dotfiles

    ln -s ~/.dotfiles/bash_profile ~/.bash_profile
    . ~/.bash_profile

Lots of things I do every day are done with 
two or three character mnemonic aliases. Please 
feel free to edit them:

    ae # alias edit
    ar # alias reload

Setup for Vim
---
To use the vim files:

    ln -s ~/.dotfiles/vimrc ~/.vimrc
    ln -s ~/.dotfiles/vim ~/.vim
    
The .vimrc is well commented and broken up by settings. I encourage you
to take a look and learn some of my handy aliases, or comment them out
if you don't like them, or make your own.

These are things I use every day to be insanely productive. Hope you like em.

 * F - instantly Find definition of class (must have exuberant ctags installed)
 * B - show Buffer explorer
 * S - Show buffers in LustyJuggler (use asdfjkl home row keys to then select buffer)
 * T - Tag list (list of methods in a class)
 * K - git grep for the Kurrent word under the cursor
 * O - Open a GitGrep command line with a quote pretyped (close the quote yourself)
 * M - show my Marks (set a mark with mX where X is a letter, navigate to mark using 'X). Uppercase marks to mark files, lowercase marks to use within a file.
 * Z - jump back and forth between last two buffers
 * Q - Quit a window (normally Ctrl-w,c)
 * \Q - Kill a buffer completely (normally :bw)
 * Ctrl-j and Ctrl-k to move up and down roughly by functions
 * vv and ss - vertical and horizontal split windows by double tapping
 * H,L,I,M - to move left, right, up, down between windows
 * Ctrl-\ - Show NerdTree (project finder) and expose current file
 * cf - Copy Filename of current file into system (not vi) paste buffer 
 * // - clear the search
 * ,, - use EasyMotion - type that and then type one of the highlighted letters. I'm just exploring this one.

Setup for Git
---
To use the gitconfig (some of the git bash aliases rely on my git aliases)

    ln -s ~/.dotfiles/gitconfig ~/.gitconfig

Read through the gitconfig to find out what's in store.

OSX Hacks
---
The osx file is a bash script that sets up sensible defaults for devs and power users
under osx. Read through it before running it. To use:

    ./osx

OSX KeyBindings for systemwide text editing
---
I am also experimenting with Brett Terpstra's OSX KeyBindings (github: ttscoff/KeyBindings) 
for good text editing features across the entire OS. To install:

    git submodule update
    mkdir -p ~/Library/KeyBindings
    ln -s KeyBindings/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBindings.dict

More info: http://brettterpstra.com/keybinding-madness/

other OSX Insane Productivity tools I use
---
 * NValt - Notational Velocity alternative fork - http://brettterpstra.com/project/nvalt/
   Dirt simple note taking, syncs to simplenote, supports all kinds of fun things like @done for todos

 * Safari Snipe extension - find an open tab. Map it to "Ctrl-/" for ultimate vim-style happiness
   http://safariextensions.tumblr.com/post/3681229291/snipe-03-06-11

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
Follow my blog: http://yanpritzker.com
