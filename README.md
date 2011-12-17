     _     _           _
    | |   | |         | |
    | |___| |_____  __| | ____
    |_____  (____ |/ _  |/ ___)
     _____| / ___ ( (_| | |
    (_______\_____|\____|_|

    # Yet Another Dotfile Repo v0.8
    # Alpha Release Please Report Bugs

    git clone https://github.com/skwp/dotfiles ~/.dotfiles
    ~/.dotfiles/bin/yadr/yadr init-plugins

    # Your dotfiles are safe! YADR will not
    # overwrite anything. Please read on for
    # install directions!

This is a collection of best of breed tools from across the web,
from scouring other people's dotfile repos, blogs, and projects.

In some ways, this is an alternative to janus (https://github.com/carlhuda/janus), offering
many of the same plugins, with minor differnces. But it's also much more,
providing shell customizations (zsh), an irb replacement (pry) with customizations,
and osx settings that are developer friendly (such as fast key repeat),
and remapping your caps-lock to be Esc for vim.

The strongly held opinions expressed here:
---
  * This configuration is for OSX, MacVim, zsh, and pry instead of irb. 
  * Apple-style philosophy: not a lot of choices, but everything Just Works and Looks Good. 
  * All common commands should be two and three character mnemonic aliases - less keystrokes, RSI reduction
  * Most used vim commands should be under your fingertips (home row, prefer Shift to other command keys)
  * Avoid stressful hand motions, e.g. remap Esc to caps lock key, remap underscore to Alt-k in vim
  * Easy to use plugin architecture, no config files to edit.
  * Pick one tool and use it everywhere: vim-ize everything
  * Colors are _important_ - solarized (http://ethanschoonover.com/solarized) is a great looking scheme that is scientifically designed to be awesome.
  * **NEW Beautiful, easy to read and small vimrc**
  * **NEW No key overrides or custom hackery in vimrc, everything in well factored snippets in .vim/plugin/settings**

Differences from janus:
---

  * Much larger and (imho) better curated list of vim plugins
  * Optimized for one color scheme (solarized) means everything Just Looks Good
  * Easy plugin management system using **yadr** command which is a thin shell over git submodules - no editing of config files
  * No need to replace your vimrc, instead uses overridable submodules (Coming Soon)
  * More than just vim plugins - great shell aliases, osx, and irb/pry tweaks to make you more productive

Before you start
---

 * Remap caps-lock to escape: http://pqrs.org/macosx/keyremap4macbook/extra.html

Installation
---

This project uses git submodules for its plugins, but this is handled
for you by the **yadr** command. Please run:

    git clone https://github.com/skwp/dotfiles ~/.dotfiles
    ~/.dotfiles/bin/yadr/yadr init-plugins

NOTE: by default, YADR will not touch any of your files. You have to manually 
activate each of its components, if you choose, by following the sections below.
Eventually these will be automated.

If you pull new changes, be sure to run this to init all the submodules:

    yadr init-plugins

After you install yadr shell aliases, you can use the *yip* alias to do the same.
Please note that init-plugins will automatically compile the CommandT plugin for you.

Setup for ZSH
---
After a lifetime of bash, I am now using ZSH as my default shell because of its awesome globbing
and autocomplete features (the spelling fixer autocomplete is worth the money alone). 

Migrating from bash to zsh is essentially pain free. The zshrc provided here
restores the only feature that I felt was 'broken' which is the Ctrl-R reverse history search.

While I am not going to support bash out of the box here, YADR _should_ work with bash if
you just source the _aliases_ file. However, you soul will sing if you install zsh. I promise.

**Install zsh pain free, automatically, with no pain:**

    wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

**Place this as the last line in your ~/.zshrc created by oh-my-zsh:**

    source ~/.dotfiles/zsh/zshrc

**Everyday shell commands should be two character mnemonic aliases**

    ae # alias edit
    ar # alias reload

**Customized zsh provided by ~/.dotfiles/zshrc:**

 * Vim mode
 * Bash style ctrl-R for reverse history finder
 * Fuzzy matching - if you mistype a directory name, tab completion will fix it

Setup for Pry
---
Pry (http://pry.github.com/) offers a much better out of the box IRB experience 
with colors, tab completion, and lots of other tricks. You should:

    gem install pry
    gem install awesome_print
    ln -s ~/.dotfiles/irb/pryrc ~/.pryrc
    ln -s ~/.dotfiles/irb/aprc ~/.aprc

**Use pry**

  * as irb: 'pry'
  * as rails console: script/console --irb=pry

**Pry customizations:**

 * 'clear' command to clear screen
 * 'sql' command to execute something (within a rails console)
 * all objects displayed in readable format (colorized, sorted hash keys) - via awesome_print
 * a few color modifications to make it more useable
 * type 'help' to see all the commands

Setup for Vim
---
To use the vim files:

    ln -s ~/.dotfiles/vimrc ~/.vimrc
    ln -s ~/.dotfiles/vim ~/.vim
    
The .vimrc is well commented and broken up by settings. I encourage you
to take a look and learn some of my handy aliases, or comment them out
if you don't like them, or make your own.

Vim Keymaps (in vim/plugin/settings)
---

The files in vim/plugin/settings are customizations stored on a per-plugin 
basis. The main keymap is available in skwp-keymap.vim, but some of the vim
files contain key mappings as well (TODO: probably will move them out to skwp-keymap.vim)

 **Navigation**

 * ,z - jump back and forth between last two buffers
 * Ctrl-\ - Show current file in nerd tree
 * Ctrl-j and Ctrl-k to move up and down roughly by functions
 * Ctrl-O - Old cursor position - this is a standard mapping but very useful, so included here
 * Ctrl-I - opposite of Ctrl-O (again, this is standard)
 * \mm - set the next available mark (set a mark with mX where X is a letter, navigate to mark using 'X). Uppercase marks to mark files, lowercase marks to use within a file.

 **LustyJuggler**

 * ,b - show buffers (LustyJuggler buffer search), just type to fuzzy match a buffer name
 * ,s - Show buffers in LustyJuggler (use asdfjkl home row keys to then select buffer)
 * ,lf - lusty file finder
 * ,lr - lusty file finder from current folder
 * ,lm ,lc ,ls - rails specific lusty juggler file finders (models, controllers, specs, etc) - just use the letter for what you want after ,l

 **Rails**

 * ,ru - Rails Unittest - synonym for :AV from rails.vim, opens up the corresponding test/spec to the file you're looking for, in a vertical split
 * \ss to run specs, \ll to run a given spec on a line - using my vim-ruby-conque plugin (https://github.com/skwp/vim-ruby-conque)

 **Surround.vim customizations**

 * in plugin/settings/surround.vim (this folder contains all my customizations)
 * the # key now surrounds with #{}, so - ysaw# surround around word #{foo}
 * = surrounds with <%= erb tag %> and - for <% this %>, so yss= or yss- to wrap code

 **Search/Code Navigation**

 * ,f - instantly Find definition of class (must have exuberant ctags installed)
 *  K - GitGrep the current word under the cursor and show results in quickfix window
 * Cmd-* - highlight all occurrences of current word (similar to regular * except doesn't move)
 * ,hl - toggle search highlight on and off
 * ,gg - GitGrep command line with a quote pretyped (close the quote yourself)
 * ,gcp - GitGrep Current Partial to find references to the current view partial
 * // - clear the search
 * ,T - Tag list (list of methods in a class)

 **RSI-reduction**

 * Cmd-k and Cmd-d to type underscores and dashes (use ), since they are so common in code but so far away from home row
 * ; instead of : - avoid Shift for common tasks, just hit semicolon to get to ex mode
 * ,. to go to last edit location instead of '. because the apostrophe is hard on the pinky

 **Tab Navigation**

 * Cmd-H and Cmd-L - left an right on tabs
 * Use Cmd-1..Cmd-0 to switch to a specific tab number (like iTerm) - and tabs have been set up to show numbers

 **Window Navigation**

 * H L I M - to move left, right, up, down between windows
 * Q -  Quit a window, keep buffer alive (Ctrl-w,c)
 * \Q - Quit window, kill buffer (:bw)

 **Splits**

 * vv - vertical split (Ctrl-w,v)
 * ss - horizontal split (Ctrl-w,s)
 * ,, to zoom a window to max size and again to unzoom it (ZoomWin standard Ctrl-w,o)
 * ,q to close the quickfix and ,oq to open the quickfix (great for lookin at Ack or GitGrep results)
 * ,m - NERDTree toggle

 **Utility**

 * ,cf - Copy Filename of current file into system (not vi) paste buffer 
 * ,cc - (Current command) copies the command under your cursor and executes it in vim. Great for testing single line changes to vimrc.
 * ,yw - yank a word from anywhere within the word (so you don't have to go to the beginning of it)
 * ,ow - overwrite a word with whatever is in your yank buffer - you can be anywhere on the word. saves having to visually select it
 * Cmd-/ - toggle comments (usually gcc from tComment)
 * gcp (comment a paragraph) added
 * ,t - Command-T fuzzy file selector (alternative to PeepOpen / LustyJuggler)

 **Local Anonymous Bookmarking**

 * ,bb - toggle local anonymous bookmark at current location
 * ,bn ,bp - next and previous anonymous bookmark
 * ,bc - clear anonymous bookmarks

Included vim plugins
---

 **Navigation**

 * NERDTree - everyone's favorite tree browser
 * NERDTree-tabs - makes NERDTree play nice with MacVim tabs so that it's on every tab
 * ShowMarks - creates a visual gutter to the left of the number column showing you your marks (saved locations). use \mt to toggle it, \mm to place the next available mark, \mh to delete, \ma to clear all. Use standard vim mark navigation ('X) for mark named X.
 * EasyMotion - hit \\w (forward) or \\b (back) and watch the magic happen. just type the letters and jump directly to your target - in the provided vimrc the keys are optimized for home and upper row, no pinkies
 * LustyJuggler/Explorer - hit B, type buf name to match a buffer, or type S and use the home row keys to select a buffer
 * TagList - hit ,T to see a list of methods in a class (uses ctags)
 * CommandT - although I personally use PeepOpen, this is available as it's pretty standard
 * VimBookmarks - toggle an anonymous bookmark ,bb and go thru them ,bn ,bp and clear them ,bc

 **Git**

 * fugitive - "a git wrapper so awesome, it should be illegal..". Try Gstatus and hit '-' to toggle files. Git 'd' to see a diff. Learn more: http://vimcasts.org/blog/2011/05/the-fugitive-series/
 * GitGrep - much better than the grep provided with fugitive; use :GitGrep or hit K to grep current word

 **Colors**

 * AnsiEsc - inteprets ansi color codes inside log files. great for looking at Rails logs
 * solarized - a color scheme scientifically calibrated for awesomeness (including skwp mods for ShowMarks)
 * csapprox - helps colors to be represented correctly on terminals (even though we expect to use MacVim)

 **Coding**

 * tComment - gcc to comment a line, gcp to comment blocks, nuff said
 * sparkup - div.foo#bar - hit ctrl-e, expands into <code><div class='foo' id#bar/></code>, and that's just the beginning
 * rails.vim - syntax highlighting, gf (goto file) enhancements, and lots more. should be required for any rails dev
 * ruby.vim - lots of general enhancements for ruby dev
 * necomplcache - intelligent and fast complete as you type, and added Command-Space to select a completion (same as Ctrl-N)
 * snipMate - offers textmate-like snippet expansion + scrooloose-snippets . try hitting TAB after typing a snippet
 * textobj-rubyblock - provides visual block selection specific to ruby. try var/vir to select a ruby block
 * vim-indentobject - manipulation of blocks by their indentation (great for yaml) use vai/vii to select around an indent block

 **Utils**

 * yankring - effortless sanity for pasting. every time you yank something it goes into a buffer. after hitting p to paste, use ctrl-p or ctrl-n to cycle through the paste options. great for when you accidentally overwrite your yank with a delete
 * surround - super easy quote and tag manipulation - ysiw" - sourround inner word with quotes. ci"' - change inner double quotes to single quotes, etc
 * greplace - use :Gsearch to find across many files, replace inside the changes, then :Greplace to do a replace across all matches
 * ConqueTerm - embedded fully colorful shell inside your vim
 * vim-ruby-conque - helpers to run ruby,rspec,rake within ConqueTerm - use \rr (ruby), \ss (rspec), \ll (rspec line), \RR (rake)
 * ruby_focused_unit_test - helpers to run tests/specs with \t
 * vim-markdown-preview - :Mm to view your README.md as html
 * html-escape - hit ctrl-h to escape html
 * ruby-debug-ide - not quite working for me, but maybe it will for you. supposedly a graphical debugger you can step through
 * Gundo - visualize your undos - pretty amazing plugin. Hit ,u with my keymappings to trigger it, very user friendly
 * space-vim - hit space to repeat many navigation commands like finds, etc. very intuitive
 * slime - use ctrl-c,ctrl-c to send text to a running irb/pry/console. To start the console, you must use screen with a named session: "screen -S [name] [cmd]", ex: "screen -S pry pry"

 **General enhancements that don't add new commands**

 * IndexedSearch - when you do searches will show you "Match 2 of 4" in the status line
 * delimitMate - automatically closes quotes 
 * syntastic - automatic syntax checking when you save the file
 * repeat - adds '.' (repeat command) support for complex commands like surround.vim. i.e. if you perform a surround and hit '.', it will Just Work (vim by default will only repeat the last piece of the complex command)
 * endwise - automatically closes blocks (if/end)
 * autotag - automatically creates tags for fast sourcecode browsing. use ctrl-[ over a symbol name to go to its definition
 * matchit - helps with matching brackets, improves other plugins


Adding your own vim plugins
---

YADR comes with a dead simple plugin manager that just uses git submodules, without any fancy config files.

    yav -u https://github.com/airblade/vim-rooter

You can update all the plugins easily:

    yuv

Delete a plugin (Coming Soon)

   ydv -p airblade-vim-rooter

The aliases (yav=yadr vim-add-plugin) and (yuv=yadr vim-update-all-plugins) live in the aliases file.
You can then commit the change. It's good to have your own fork of this project to do that.

Setup for Git
---
**To use the gitconfig (some of the git bash aliases rely on my git aliases)**

    ln -s ~/.dotfiles/gitconfig ~/.gitconfig

Since the gitconfig doesn't contain the user info, I recommend using env variables.

**Put the following in your ~/.secrets file which is automatically referenced by the provided zshrc:**

    export GIT_AUTHOR_NAME=yourname
    export GIT_AUTHOR_EMAIL=you@domain.com
    export GIT_COMITTER_NAME=yourname
    export GIT_COMITTER_EMAIL=you@domain.com

**Some of the customizations provided include:**

  * git l - a much more usable git log
  * git b - a list of branches with summary of last commit
  * git r - a list of remotes with info
  * git t - a list of tags with info
  * git nb - a (n)ew (b)ranch - like checkout -b
  * git cp - cherry-pick -x (showing what was cherrypicked)
  * git changelog - a nice format for creating changelogs
  * Some sensible default configs, such as improving merge messages, push only pushes the current branch, removing status hints, and using mnemonic prefixes in diff: (i)ndex, (w)ork tree, (c)ommit and (o)bject 
  * Slightly imrpoved colors for diff
  * git unstage (remove from index) and git uncommit (revert to the time prior to the last commit - dangerous if already pushed) aliases

OSX Hacks
---
The osx file is a bash script that sets up sensible defaults for devs and power users
under osx. Read through it before running it. To use:

    ./osx

These hacks are Lion-centric. May not work for other OS'es. My favorite mods include:

  * Ultra fast key repeat rate (now you can scroll super quick using j/k)
  * No disk image verification (downloaded files open quicker) 
  * Display the ~/Library folder in finder (hidden in Lion)

Other recommended OSX tools 
---
 * NValt - Notational Velocity alternative fork - http://brettterpstra.com/project/nvalt/ - syncs with SimpleNote
 * Vimium for Chrome - vim style browsing. The 'f' to type the two char alias of any link is worth it.
 * QuickCursor - gives you Apple-Shift-E to edit any OSX text field in vim.

Credits
---

I can't take credit for all of this. The vim files are a combination of
work by tpope, scrooloose, and many hours of scouring blogs, vimscripts,
and other places for the cream of the crop of vim awesomeness.

 * https://github.com/astrails/dotvim
 * https://github.com/carlhuda/janus
 * https://github.com/tpope
 * https://github.com/scrooloose
 * https://github.com/kana
 * https://github.com/robbyrussell
 * https://github.com/nelstrom

And everything that's in the modules included in vim/bundle of course.
Please explore these people's work.

COMING SOON
---
 * Better isolation of customizations in smaller chunks, maybe as plugins
 * Automatic setup script to symlink all dotfiles, or just some selectively 

For more tips and tricks
---
Follow my blog: http://yanpritzker.com
