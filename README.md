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

What is YADR?
---

**YADR is an opinionated dotfile repo that will make your heart sing**

  * OSX is the best OS. MacVim is the best editor. Zsh is the best shell. Pry is the best irb. Solarized is the best color scheme.
  * Apple-style philosophy: make everything Just Work and Look Good. Don't worry about too many options.
  * All common commands should be two and three character mnemonic aliases - less keystrokes, RSI reduction
  * Avoid stressful hand motions, e.g. remap Esc to caps lock key, remap underscore to Alt-k in vim, make window management in vim easy.
  * Easy to use plugin architecture, no config files to edit.
  * Pick one tool and use it everywhere: vim-ize everything
  * **NEW Beautiful, easy to read and small vimrc**
  * **NEW No key overrides or custom hackery in vimrc, everything in well factored snippets in .vim/plugin/settings**

Why is this not a fork of Janus?
---
Janus is an amazing _first effort_ to deliver a ready-to-use vim setup and is a huge inspiration to us all.

**However as any first effort, it paves the way to improvements:**

  * Much larger list of vim plugins, specifically geared to Ruby/Rails/Git development.
  * Optimized support for MacVim only means less things will break because we don't worry about linux or gvim.
  * Optimized support for Solarized color scheme only, everything guaranteed to Look Good. Your eyes will thank you.
  * All plugins tested with Solarized and custom color maps provided where needed to ensure your eyes will not bleed.
  * No configuration file to maintain. YADR uses tiny ruby scripts to wrap git submodule maintenance.
  * Much cleaner vimrc that does not introduce any new key maps. (Janus: 160 lines vimrc, 260 lines gvimrc; YADR: 90 lines vimrc with great comments)
  * All keymaps and customization in small, easy to maintain files under .vim/plugin/settings
  * More than just vim plugins - great shell aliases, osx, and irb/pry tweaks to make you more productive.

Screenshot
---
![screenshot](http://i.imgur.com/lEFlF.png)

Before you start
---

For the love of all that is holy, stop abusing your hands!
Remap caps-lock to escape: http://pqrs.org/macosx/keyremap4macbook/extra.html

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

**Install zsh pain free, automatically:**

    wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

Place this as the last line in your ~/.zshrc created by oh-my-zsh:

    source ~/.dotfiles/zsh/zshrc

Or, to make things simpler you can just use the YADR-provided zsh/oh_my_zsh_zshrc
Please note that this relies on the skwp fork of oh-my-zsh which contains skwp.theme

    ln -sf ~/.dotfiles/zsh/oh_my_zsh_zshrc ~/.zshrc

Lots of things I do every day are done with two or three character
mnemonic aliases. Please feel free to edit them:

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
 * Ctrl-j and Ctrl-k to move up and down roughly by functions
 * Ctrl-o - Old cursor position - this is a standard mapping but very useful, so included here
 * Ctrl-i - opposite of Ctrl-O (again, this is standard)

 **Marks**

 * ,mm - set the next available mark (set a mark with mX where X is a letter, navigate to mark using 'X). Uppercase marks to mark files, lowercase marks to use within a file.
 * ,ma - clear all marks
 * ,mh - clear current mark
 * ,Bt - toggle local anonymous bookmark at current location
 * ,Bn ,Bp - next and previous anonymous bookmark
 * ,Bc - clear anonymous bookmarks

 **LustyJuggler**

 * ,lj - show buffers (LustyJuggler buffer search), just type to fuzzy match a buffer name

 **Rails**

 * ,ru - Rails Unittest - synonym for :AV from rails.vim, opens up the corresponding test/spec to the file you're looking for, in a vertical split
 * ,ss to run specs, ,ll to run a given spec on a line - using my vim-ruby-conque plugin (https://github.com/skwp/vim-ruby-conque)
 * Cmd-Shift-R to use vim-rspec to run a spec file. Cmd-Shift-L to run from a line (individual it block)

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
 * ,q/ -  quickfix window with last search (stolen from Steve Losh)
 * ,qa/ - quickfix Ack last search (Steve Losh)
 * ,qg/ - quickfix GitGrep last search
 * ,T - Tag list (list of methods in a class)

 **File Navigation**

 * ,t - Command-T fuzzy file selector
 * ,b - Command-T buffer selector
 * ,jm jump (command-t) app/models
 * ,jc app/controllers
 * ,jv app/views
 * ,jh app/helpers
 * ,jl lib
 * ,jp public
 * ,js spec
 * ,jf fast_spec
 * ,jt test
 * ,jd db
 * ,jC config
 * ,jV vendor
 * ,jF factories

 **RSI-reduction**

 * Cmd-k and Cmd-d to type underscores and dashes (use Shift), since they are so common in code but so far away from home row
 * ; instead of : - avoid Shift for common tasks, just hit semicolon to get to ex mode
 * ,. to go to last edit location instead of '. because the apostrophe is hard on the pinky
 * Cmd-' and Cmd-" to change content inside quotes

 **Tab Navigation**

 * Ctrl-H and Ctrl-L - left an right on tabs
 * Use Cmd-1..Cmd-0 to switch to a specific tab number (like iTerm) - and tabs have been set up to show numbers

 **Window Navigation**

 * H L I M - to move left, right, up, down between windows
 * Q - Intelligent Window Killer. Close window (wincmd c) if there are multiple windows to same buffer, or kill the buffer (bwipeout) if this is the last window into it.

 **Splits**

 * vv - vertical split (Ctrl-w,v)
 * ss - horizontal split (Ctrl-w,s)
 * ,, - zoom a window to max size and again to unzoom it (ZoomWin plugin, usually C-w,o)
 * ,qo - open quickfix window (this is where output from GitGrep goes)
 * ,qc - close quickfix

 **NERDTree Project Tree**

 * Cmd-N - NERDTree toggle
 * Ctrl-\ - Show current file tree

 **Utility**

 * ,ig - toggle visual indentation guides
 * ,cf - Copy Filename of current file into system (not vi) paste buffer
 * ,cc - (Current command) copies the command under your cursor and executes it in vim. Great for testing single line changes to vimrc.
 * ,yw - yank a word from anywhere within the word (so you don't have to go to the beginning of it)
 * ,ow - overwrite a word with whatever is in your yank buffer - you can be anywhere on the word. saves having to visually select it
 * ,w - strip trailing whitespaces
 * sj - split a line such as a hash {:foo => {:bar => :baz}} into a multiline hash (j = down)
 * sk - unsplit a link (k = up)
 * Cmd-Shift-A - align things (type a character/expression to align by, works in visual mode or by itself)

 **Comments**

 * Cmd-/ - toggle comments (usually gcc from tComment)
 * gcp (comment a paragraph)

Included vim plugins
---

 **Navigation**

 * NERDTree - everyone's favorite tree browser
 * NERDTree-tabs - makes NERDTree play nice with MacVim tabs so that it's on every tab
 * ShowMarks - creates a visual gutter to the left of the number column showing you your marks 
 * EasyMotion - hit ,,w (forward) or ,,b (back) and watch the magic happen. just type the letters and jump directly to your target - in the provided vimrc the keys are optimized for home and upper row, no pinkies
 * LustyJuggler/Explorer - hit B, type buf name to match a buffer, or type S and use the home row keys to select a buffer
 * TagList - hit ,T to see a list of methods in a class (uses ctags)
 * CommandT - ,t to find a file
 * VimBookmarks - toggle an anonymous bookmark ,bb and go thru them ,bn ,bp and clear them ,bc
 * TabMan - hit ,mt to see all tabs and buffers in a tree. Easy to navigate and close.

 **Git**

 * fugitive - "a git wrapper so awesome, it should be illegal..". Try Gstatus and hit '-' to toggle files. Git 'd' to see a diff. Learn more: http://vimcasts.org/blog/2011/05/the-fugitive-series/
 * extradite - use :Extradite to get a really great git log browser. Only works when you have a file open.
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
 * jasmine.vim - support for jasmine javascript unit testing, including snippets for it, before, etc..

 **TextObjects**

 The things in this section provide new "objects" to work with your standard verbs such as yank/delete/change/=(codeformat), etc

 * textobj-rubyblock - ruby blocks become vim textobjects denoted with 'r'. try var/vir to select a ruby block, dar/dir for delete car/cir for change, =ar/=ir for formatting, etc
 * vim-indentobject - manipulate chunks of code by indentation level (great for yaml) use vai/vii to select around an indent block, same as above applies
 * argtextobj - manipulation of function arguments as an "a" object, so vaa/via, caa/cia, daa/dia, etc..
 * textobj-datetime - gives you 'da' (date), 'df' (date full) and so on text objects. useable with all standard verbs
 * vim-textobj-entire - gives you 'e' for entire document. so vae (visual around entire document), and etc
 * vim-textobj-rubysymbol - gives you ':' textobj. so va: to select a ruby symbol. da: to delete a symbol..etc

 **Utils**

 * SplitJoin - easily split up things like ruby hashes into multiple lines or join them back together. Try :SplitjoinJoin and :SplitjoinSplit or use the bindings sj(split) and sk(unsplit) - mnemonically j and k are directions down and up
 * tabularize - align code effortlessly by using :Tabularize /[character] to align by a character, or try the keymaps
 * yankring - effortless sanity for pasting. every time you yank something it goes into a buffer. after hitting p to paste, use ctrl-p or ctrl-n to cycle through the paste options. great for when you accidentally overwrite your yank with a delete
 * surround - super easy quote and tag manipulation - ysiw" - sourround inner word with quotes. ci"' - change inner double quotes to single quotes, etc
 * greplace - use :Gsearch to find across many files, replace inside the changes, then :Greplace to do a replace across all matches
 * ConqueTerm - embedded fully colorful shell inside your vim
 * vim-ruby-conque - helpers to run ruby,rspec,rake within ConqueTerm - use ,rr (ruby), ,ss (rspec), ,ll (rspec line), ,RR (rake)
 * vim-rspec - really clean and colorful rspec output (Cmd-Shift-R) with ability to navigate directly to error; will replace vim-ruby-conque when I do a couple enhancements/bug fixes
 * vim-markdown-preview - :Mm to view your README.md as html
 * html-escape - hit ctrl-h to escape html
 * ruby-debug-ide - not quite working for me, but maybe it will for you. supposedly a graphical debugger you can step through
 * Gundo - visualize your undos - pretty amazing plugin. Hit ,u with my keymappings to trigger it, very user friendly
 * slime - use ctrl-c,ctrl-c to send text to a running irb/pry/console. To start the console, you must use screen with a named session: "screen -S [name] [cmd]", ex: "screen -S pry pry"
 * vim-indent-guides - visual indent guides, off by default

 **General enhancements that don't add new commands**

 * IndexedSearch - when you do searches will show you "Match 2 of 4" in the status line
 * delimitMate - automatically closes quotes
 * syntastic - automatic syntax checking when you save the file
 * repeat - adds '.' (repeat command) support for complex commands like surround.vim. i.e. if you perform a surround and hit '.', it will Just Work (vim by default will only repeat the last piece of the complex command)
 * endwise - automatically closes blocks (if/end)
 * autotag - automatically creates tags for fast sourcecode browsing. use ctrl-[ over a symbol name to go to its definition
 * matchit - helps with matching brackets, improves other plugins
 * sass-status - decorates your status bar with full nesting of where you are in the sass file


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
 * brew install autojump - will track your commonly used directories and let you jump there. With the zsh plugin you can just type 'j [dirspec]', a few letters of the dir you want to go to.]'

Credits
---

I can't take credit for all of this. The vim files are a combination of
work by tpope, scrooloose, and many hours of scouring blogs, vimscripts,
and other places for the cream of the crop of vim awesomeness.

 * http://ethanschoonover.com/solarized - a scientifically calibrated color scheme
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
