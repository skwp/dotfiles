     _     _           _
    | |   | |         | |
    | |___| |_____  __| | ____
    |_____  (____ |/ _  |/ ___)
     _____| / ___ ( (_| | |
    (_______\_____|\____|_|

    # Yet Another Dotfile Repo v0.9
    # Alpha Release Please Report Bugs

    git clone https://github.com/skwp/dotfiles ~/.yadr
    cd ~/.yadr && rake install

    # Your dotfiles are safe! YADR will not
    # overwrite anything. Please read on for
    # install directions!

This is a collection of best of breed tools from across the web,
from scouring other people's dotfile repos, blogs, and projects.


## What is YADR?

**YADR is an opinionated dotfile repo that will make your heart sing**

  * OSX is the best OS. MacVim is the best editor. Zsh is the best shell. Pry is the best irb. Solarized is the best color scheme.
  * Apple-style philosophy: make everything Just Work and Look Good. Don't worry about too many options.
  * All common commands should be two and three character mnemonic aliases - less keystrokes, RSI reduction
  * Avoid stressful hand motions, e.g. remap Esc to caps lock key, remap underscore to Alt-k in vim, make window management in vim easy.
  * Easy to use plugin architecture, no config files to edit.
  * Pick one tool and use it everywhere: vim-ize everything
  * **NEW Beautiful, easy to read and small vimrc**
  * **NEW No key overrides or custom hackery in vimrc, everything in well factored snippets in .vim/plugin/settings**


## Why is this not a fork of Janus?
Janus is an amazing _first effort_ to deliver a ready-to-use vim setup and is a huge inspiration to us all.

**However as any first effort, it paves the way to improvements:**

  * Much larger list of vim plugins, specifically geared to Ruby/Rails/Git development.
  * Optimized support for MacVim only means less things will break because we don't worry about linux or gvim.
  * Optimized support for Solarized color scheme only, everything guaranteed to Look Good. Your eyes will thank you.
  * All plugins tested with Solarized and custom color maps provided where needed to ensure your eyes will not bleed.
  * No configuration file to maintain. YADR uses tiny ruby scripts to wrap git submodule maintenance.
  * Much cleaner vimrc that keps keymaps isolated to a plugin file (not in the main vimrc).
  * All keymaps and customization in small, easy to maintain files under .vim/plugin/settings
  * More than just vim plugins - great shell aliases, osx, and irb/pry tweaks to make you more productive.


## Screenshot
![screenshot](http://i.imgur.com/afzuR.png)


## Before you start

For the love of all that is holy, stop abusing your hands!
Remap caps-lock to escape: http://pqrs.org/macosx/keyremap4macbook/extra.html

## Debugging vim keymappings

This is so useful, it needs to be at the top. If you are having unexpected behavior, wondering why a particular key works the way it does,
use: `:map [keycombo]` (e.g. `:map <C-\>`) to see what the key is mapped to. For bonus points, you can see where the mapping was set by using `:verbose map [keycombo]`.
If you omit the key combo, you'll get a list of all the maps. You can do the same thing with nmap, imap, vmap, etc.

## Dependencies

YADR is opinionated. To get the most out of using it, you should install
all the software it depends on.

### Patched fonts for Vim-Powerline

Please install fonts from fonts/ directory. These are used to give a really nice vim status line.

### [Homebrew](http://mxcl.github.com/homebrew/)

Homebrew is _the missing package manager for OSX_. To install:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.github.com/gist/323731)"
```

With homebrew installed, install some packages:

```bash
brew install ack ctags git hub macvim
```

### [ctags](http://ctags.sourceforge.net/)

Vim will complain every time you save a file if you do not have ctags installed correctly. We
assume you have installed ctags via homebrew. If you have homebrew setup correctly running
`which ctags` should output `/usr/local/bin/ctags`. If you get something else do this:

Make sure `/usr/local/bin` is before `/usr/bin` in your PATH.

If that doesn't work, move the OSX supplied ctags [like so](http://www.mattpolito.info/post/1648956809/ctags-got-you-down):

```bash
sudo mv /usr/bin/ctags /usr/bin/ctags_original
```

### [oh-my-zsh](https://github.com/sorin-ionescu/oh-my-zsh)

`git clone https://github.com/sorin-ionescu/oh-my-zsh.git ~/.oh-my-zsh`
`cd ~/.oh-my-zsh && git submodule update --init --recursive`

We prefer the @sorin-ionescu rewrite of Oh My Zsh. It will eventually be shipped
as a submodule of YADR, although you can use the original @robbyrussell version as well.

You only need to do the two commands above. The rest of the installation is done
by YADR, which ships with a tie-in to sorin's OMZ.

### [fasd](https://github.com/clvv/fasd)

fasd gives you handy shell commands `f`,`a`,`s`,`d`, and `z` to jump to recently used files.
Read more at the project's home page. Or just type `z` followed by a partial reference to
a recent directory to see how it works.

## Installation

Installation is automated via `rake` and the `yadr` command. To get
started please run:

```bash
git clone https://github.com/skwp/dotfiles ~/.yadr
cd ~/.yadr && rake install
```

Open the fonts in fonts/ and click Install Font for every font that you want.
You must install Inconsolata to have YADR's powerline theme work correctly out of the box.

Note: YADR will not destroy any of your files unless you tell it to.


## Upgrading

Upgrading is easy.

```bash
cd ~/.yadr
git pull origin master
rake install
```


## ZSH

After a lifetime of bash, I am now using ZSH as my default shell because of its awesome globbing
and autocomplete features (the spelling fixer autocomplete is worth the money alone).

Migrating from bash to zsh is essentially pain free. The zshrc provided here
restores the only feature that I felt was 'broken' which is the Ctrl-R reverse history search.

While I am not going to support bash out of the box here, YADR _should_ work with bash if
you just source the _aliases_ file. However, you soul will sing if you install zsh. I promise.

Lots of things I do every day are done with two or three character
mnemonic aliases. Please feel free to edit them:

    ae # alias edit
    ar # alias reload

### ZSH Customizations

 * Vim mode
 * Bash style ctrl-R for reverse history finder
 * Ctrl-x,Ctrl-l to insert output of last command
 * Fuzzy matching - if you mistype a directory name, tab completion will fix it

### How To Customize ZSH

YADR allows you to completely customize your ZSH without having to fork and maintain the project. Here's how it works: YADR will
source (include) any files in `.yadr/custom/zsh/before/*` or `.yadr/custom/zsh/after/*`. The `before` files are
useful for setting the theme and plugins. `after` files allow you to override options set by YADR, define your own aliases, etc.

To make your life easier, create a `zsh` folder in your Dropbox (or as a git repo) and symlink it into `~/.yadr/custom`. Do it like this:

```bash
ln -s ~/Dropbox/path/to/zsh ~/.yadr/custom/zsh
```

Create as many `before/whatever.zsh` or `after/whatever.zsh` files as you need within the `zsh` directory. Please see `custom/zsh.sample` for
an example.


## Pry

Pry (http://pry.github.com/) offers a much better out of the box IRB experience
with colors, tab completion, and lots of other tricks. You should:

### Install the gem

```bash
gem install pry
gem install awesome_print
```

### Use pry

  * as irb: `pry`
  * as rails console: `script/console --irb=pry`

### Pry Customizations:

 * `clear` command to clear screen
 * `sql` command to execute something (within a rails console)
 * all objects displayed in readable format (colorized, sorted hash keys) - via awesome_print
 * a few color modifications to make it more useable
 * type `help` to see all the commands


## Git

### User Info

Since the gitconfig doesn't contain the user info, I recommend using env variables. Put the following in
your `~/.secrets` file which is automatically referenced by the provided zshrc:

    # Set your git user info
    export GIT_AUTHOR_NAME='Your Name'
    export GIT_AUTHOR_EMAIL='you@domain.com'
    export GIT_COMMITTER_NAME='Your Name'
    export GIT_COMMITTER_EMAIL='you@domain.com'

    # Optionally, set your GitHub credentials
    export GITHUB_USER='your_user_name'
    export GITHUB_TOKEN='your_github_token'

### Git Customizations:

  * `git l` - a much more usable git log
  * `git b` - a list of branches with summary of last commit
  * `git r` - a list of remotes with info
  * `git t` - a list of tags with info
  * `git nb` - a (n)ew (b)ranch - like checkout -b
  * `git cp` - cherry-pick -x (showing what was cherrypicked)
  * `git changelog` - a nice format for creating changelogs
  * Some sensible default configs, such as improving merge messages, push only pushes the current branch, removing status hints, and using mnemonic prefixes in diff: (i)ndex, (w)ork tree, (c)ommit and (o)bject
  * Slightly improved colors for diff
  * `git unstage` (remove from index) and `git uncommit` (revert to the time prior to the last commit - dangerous if already pushed) aliases

## RubyGems

A .gemrc is included. Never again type `gem install whatever --no-ri --no-rdoc`. `--no-ri --no-rdoc` is done by default.


## Vim Configuration

The .vimrc is well commented and broken up by settings. I encourage you
to take a look and learn some of my handy aliases, or comment them out
if you don't like them, or make your own.


### Vim Keymaps

The files in vim/plugin/settings are customizations stored on a per-plugin
basis. The main keymap is available in skwp-keymap.vim, but some of the vim
files contain key mappings as well (TODO: probably will move them out to skwp-keymap.vim)

#### Navigation

 * `,z` - go to previous buffer (:bp)
 * `,x` - go to next buffer (:bn)
 * `Cmd-j` and `Cmd-k` to move up and down roughly by functions
 * `Ctrl-o` - Old cursor position - this is a standard mapping but very useful, so included here
 * `Ctrl-i` - opposite of Ctrl-O (again, this is standard)

#### LustyJuggler

 * `,lj` - show buffers (LustyJuggler buffer search), just type to fuzzy match a buffer name
 * `,lf` - file system browser

#### Rails

 * `,ss` to run specs, `,ll` to run a given spec on a line - using my [vim-ruby-conque plugin](https://github.com/skwp/vim-ruby-conque)
 * `Cmd-Shift-R` to use vim-ruby-conque to run a spec file. `Cmd-Shift-L` to run from a line (individual it block), `,Cmd-Shift-R` to rerun the last run command (great for re-running specs)

#### Surround.vim customizations

 * in plugin/settings/surround.vim (this folder contains all my customizations)
 * the `#` key now surrounds with `#{}`, so `ysaw#` (surround around word) `#{foo}`
 * `=` surrounds with `<%= erb tag %>`; `-` for `<% this %>`. So, `yss=` or `yss-` to wrap code

#### Search/Code Navigation

 * `,f` - instantly Find definition of class (must have exuberant ctags installed)
 * `,F` - same as ,f but in a vertical split
 * `,gf` - same as vim normal gf (go to file), but in a vertical split
 * `K` - GitGrep the current word under the cursor and show results in quickfix window
 * `,K` - GitGrep the current word up to next exclamation point (useful for ruby foo! methods)
 * `Cmd-*` - highlight all occurrences of current word (similar to regular `*` except doesn't move)
 * `,hl` - toggle search highlight on and off
 * `,gg` - GitGrep command line, type between quotes
 * `,gd` - GitGrep def (greps for 'def [function name]') when cursor is over the function name
 * `,gcp` - GitGrep Current Partial to find references to the current view partial
 * `,gcf` - GitGrep Current File to find references to the current file
 * `//` - clear the search
 * `,q/` -  quickfix window with last search (stolen from Steve Losh)
 * `,qa/` - quickfix Ack last search (Steve Losh)
 * `,qg/` - quickfix GitGrep last search
 * `,T` - Tag list (list of methods in a class)
 * `Ctrl-s` - Open related spec in a split. Similar to :A and :AV from rails.vim but is also aware of the fast_spec dir and faster to type

#### File Navigation

 * `,t` - CtrlP fuzzy file selector
 * `,b` - CtrlP buffer selector
 * `Cmd-Shift-P` - Clear CtrlP cache
 * `,jm` jump (via CtrlP) to app/models
 * `,jc` app/controllers
 * `,jv` app/views
 * `,jh` app/helpers
 * `,jl` lib
 * `,jp` public
 * `,js` spec
 * `,jf` fast_spec
 * `,jt` test
 * `,jd` db
 * `,jC` config
 * `,jV` vendor
 * `,jF` factories

#### RSI-reduction

 * `Cmd-k` and `Cmd-d` to type underscores and dashes (use Shift), since they are so common in code but so far away from home row
 * `Cmd-k` and `Cmd-d` to type underscores and dashes (use Shift), since they are so common in code but so far away from home row
 * `Ctrl-l` to insert a => hashrocket (thanks @garybernhardt)
 * `,.` to go to last edit location (same as `'.`) because the apostrophe is hard on the pinky
 * `Cmd-'` and `Cmd-"` to change content inside quotes
 * Cmd-Space to autocomplete. Tab for snipmate snippets.
 * `,ci` to change inside any set of quotes/brackets/etc

#### Tab Navigation

 * `Ctrl-H` and `Ctrl-L` - left an right on tabs
 * Use `Cmd-1` thru `Cmd-9` to switch to a specific tab number (like iTerm) - and tabs have been set up to show numbers

#### Window Navigation

 * `Ctrl-h,l,j,k` - to move left, right, down, up between windows
 * `Q` - Intelligent Window Killer. Close window `wincmd c` if there are multiple windows to same buffer, or kill the buffer `bwipeout` if this is the last window into it.
 * Cmd-Arrow keys - resize windows (up/down for vertical, left=make smaller horizontally, right=make bigger horizontally)

#### Splits

 * `vv` - vertical split (`Ctrl-w,v`)
 * `ss` - horizontal split (`Ctrl-w,s`)
 * `,qo` - open quickfix window (this is where output from GitGrep goes)
 * `,qc` - close quickfix
 * `,gz` - zoom a window to max size and again to unzoom it (ZoomWin plugin, usually `C-w,o`)

#### NERDTree Project Tree

 * `Cmd-Shift-N` - NERDTree toggle
 * `Ctrl-\` - Show current file tree

#### Utility

 * `,ig` - toggle visual indentation guides
 * `,cf` - Copy Filename of current file (full path) into system (not vi) paste buffer
 * `,cn` - Copy Filename of current file (name only, no path)
 * `,vc` - (Vim Command) copies the command under your cursor and executes it in vim. Great for testing single line changes to vimrc.
 * `,vr` - (Vim Reload) source current file as a vim file
 * `,yw` - yank a word from anywhere within the word (so you don't have to go to the beginning of it)
 * `,ow` - overwrite a word with whatever is in your yank buffer - you can be anywhere on the word. saves having to visually select it
 * `,ocf` - open changed files (stolen from @garybernhardt). open all files with git changes in splits
 * `,w` - strip trailing whitespaces
 * `sj` - split a line such as a hash {:foo => {:bar => :baz}} into a multiline hash (j = down)
 * `sk` - unsplit a link (k = up)
 * `,he` - Html Escape
 * `,hu` - Html Unescape
 * `Cmd-Shift-A` - align things (type a character/expression to align by, works in visual mode or by itself)
 * `:ColorToggle` - turn on #abc123 color highlighting (useful for css)
 * `:gitv` - Git log browsers
 * `,hi` - show current Highlight group. if you don't like the color of something, use this, then use `hi! link [groupname] [anothergroupname]` in your vimrc.after to remap the color. You can see available colors using `:hi`

#### Comments

 * `Cmd-/` - toggle comments (usually gcc from tComment)
 * `gcp` (comment a paragraph)

 **Wrapping**

 * :Wrap - wrap long lines (e.g. when editing markdown files).
 * Cmd-[j, k, $, 0, ^] - navigate display lines.

### Included vim plugins

#### Navigation

 * NERDTree - everyone's favorite tree browser
 * NERDTree-tabs - makes NERDTree play nice with MacVim tabs so that it's on every tab
 * ShowMarks - creates a visual gutter to the left of the number column showing you your marks
 * EasyMotion - hit ,,w (forward) or ,,b (back) and watch the magic happen. just type the letters and jump directly to your target - in the provided vimrc the keys are optimized for home and upper row, no pinkies
 * LustyJuggler/Explorer - hit B, type buf name to match a buffer, or type S and use the home row keys to select a buffer
 * TagBar - hit ,T to see a list of methods in a class (uses ctags)
 * CtrlP - Ctrl-p or ,t to find a file

#### Git

 * fugitive - "a git wrapper so awesome, it should be illegal...". Try Gstatus and hit `-` to toggle files. Git `d` to see a diff. Learn more: http://vimcasts.org/blog/2011/05/the-fugitive-series/
 * gitv - use :gitv for a better git log browser
 * GitGrep - much better than the grep provided with fugitive; use :GitGrep or hit K to grep current word

#### Colors

 * AnsiEsc - inteprets ansi color codes inside log files. great for looking at Rails logs
 * solarized - a color scheme scientifically calibrated for awesomeness (including skwp mods for ShowMarks)
 * csapprox - helps colors to be represented correctly on terminals (even though we expect to use MacVim)
 * Powerline - beautiful vim status bar. Requires patched fonts (install from fonts/ directory)

#### Coding

 * tComment - gcc to comment a line, gcp to comment blocks, nuff said
 * sparkup - div.foo#bar - hit `ctrl-e`, expands into `<div class="foo" id="bar"/>`, and that's just the beginning
 * rails.vim - syntax highlighting, gf (goto file) enhancements, and lots more. should be required for any rails dev
 * ruby.vim - lots of general enhancements for ruby dev
 * necomplcache - intelligent and fast complete as you type, and added Command-Space to select a completion (same as Ctrl-N)
 * snipMate - offers textmate-like snippet expansion + scrooloose-snippets . try hitting TAB after typing a snippet
 * jasmine.vim - support for jasmine javascript unit testing, including snippets for it, before, etc..
 * vim-coffeescript - support for coffeescript, highlighting
 * vim-stylus - support for stylus css language

#### TextObjects

 The things in this section provide new "objects" to work with your standard verbs such as yank/delete/change/=(codeformat), etc

 * textobj-rubyblock - ruby blocks become vim textobjects denoted with `r`. try var/vir to select a ruby block, dar/dir for delete car/cir for change, =ar/=ir for formatting, etc
 * vim-indentobject - manipulate chunks of code by indentation level (great for yaml) use vai/vii to select around an indent block, same as above applies
 * argtextobj - manipulation of function arguments as an "a" object, so vaa/via, caa/cia, daa/dia, etc..
 * textobj-datetime - gives you `da` (date), `df` (date full) and so on text objects. useable with all standard verbs
 * vim-textobj-entire - gives you `e` for entire document. so vae (visual around entire document), and etc
 * vim-textobj-rubysymbol - gives you `:` textobj. so va: to select a ruby symbol. da: to delete a symbol..etc
 * vim-textobj-function - gives you `f` textobj. so vaf to select a function
 * next-textobject - from Steve Losh, ability to use `n` such as vinb (visual inside (n)ext set of parens)

#### Utils

 * SplitJoin - easily split up things like ruby hashes into multiple lines or join them back together. Try :SplitjoinJoin and :SplitjoinSplit or use the bindings sj(split) and sk(unsplit) - mnemonically j and k are directions down and up
 * tabularize - align code effortlessly by using :Tabularize /[character] to align by a character, or try the keymaps
 * yankring - effortless sanity for pasting. every time you yank something it goes into a buffer. after hitting p to paste, use ctrl-p or ctrl-n to cycle through the paste options. great for when you accidentally overwrite your yank with a delete
 * surround - super easy quote and tag manipulation - ysiw" - sourround inner word with quotes. ci"' - change inner double quotes to single quotes, etc
 * greplace - use :Gsearch to find across many files, replace inside the changes, then :Greplace to do a replace across all matches
 * ConqueTerm - embedded fully colorful shell inside your vim
 * vim-ruby-conque - helpers to run ruby,rspec,rake within ConqueTerm
 * vim-markdown-preview - :Mm to view your README.md as html
 * html-escape - ,he and ,hu to escape and unescape html
 * ruby-debug-ide - not quite working for me, but maybe it will for you. supposedly a graphical debugger you can step through
 * Gundo - visualize your undos - pretty amazing plugin. Hit ,u with my keymappings to trigger it, very user friendly
 * slime - use ctrl-c,ctrl-c to send text to a running irb/pry/console. To start the console, you must use screen with a named session: "screen -S [name] [cmd]", ex: "screen -S pry pry"
 * vim-indent-guides - visual indent guides, off by default
 * color_highlight - use :ColorCodes to see hex colors highlighted
 * change-inside-surroundings - change content inside delimiters like quotes/brackets
 * Specky - used for color highlighting rspec correctly even if specs live outside of spec/ (rails.vim doesn't handle this)

#### General enhancements that don't add new commands

 * Arpeggio - allows you to define key-chord combinations
 * IndexedSearch - when you do searches will show you "Match 2 of 4" in the status line
 * delimitMate - automatically closes quotes
 * syntastic - automatic syntax checking when you save the file
 * repeat - adds `.` (repeat command) support for complex commands like surround.vim. i.e. if you perform a surround and hit `.`, it will Just Work (vim by default will only repeat the last piece of the complex command)
 * endwise - automatically closes blocks (if/end)
 * autotag - automatically creates tags for fast sourcecode browsing. use ctrl-[ over a symbol name to go to its definition
 * matchit - helps with matching brackets, improves other plugins
 * sass-status - decorates your status bar with full nesting of where you are in the sass file


### Overriding vim settings

You may use `~/.vimrc.before` for settings like the __leader__ setting. You may `~/.vimrc.after` for any additional overrides/settings.


### Adding your own vim plugins

YADR comes with a dead simple plugin manager that just uses git submodules, without any fancy config files.

    yav -u https://github.com/airblade/vim-rooter

You can update all the plugins easily:

    yuv

Delete a plugin (Coming Soon)

   ydv -p airblade-vim-rooter

The aliases (yav=yadr vim-add-plugin) and (yuv=yadr vim-update-all-plugins) live in the aliases file.
You can then commit the change. It's good to have your own fork of this project to do that.


## Miscellaneous


### OSX Hacks
The osx file is a bash script that sets up sensible defaults for devs and power users
under osx. Read through it before running it. To use:

    ./osx

These hacks are Lion-centric. May not work for other OS'es. My favorite mods include:

  * Ultra fast key repeat rate (now you can scroll super quick using j/k)
  * No disk image verification (downloaded files open quicker)
  * Display the ~/Library folder in finder (hidden in Lion)


### Other recommended OSX tools

 * NValt - Notational Velocity alternative fork - http://brettterpstra.com/project/nvalt/ - syncs with SimpleNote
 * Vimium for Chrome - vim style browsing. The `f` to type the two char alias of any link is worth it.
 * QuickCursor - gives you Apple-Shift-E to edit any OSX text field in vim.
 * brew install autojump - will track your commonly used directories and let you jump there. With the zsh plugin you can just type `j [dirspec]`, a few letters of the dir you want to go to.


### Credits

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


### Contributors

 * Initial Version: @skwp
 * Cleanup, auto installer: @kylewest


### For more tips and tricks

Follow my blog: http://yanpritzker.com

