     _     _           _
    | |   | |         | |
    | |___| |_____  __| | ____
    |_____  (____ |/ _  |/ ___)
     _____| / ___ ( (_| | |
    (_______\_____|\____|_|

    # Yet Another Dotfile Repo v1.1
    # Now with Prezto and Vundle!

[![Join the chat at https://gitter.im/skwp/dotfiles](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/skwp/dotfiles?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

#### sh -c "\`curl -fsSL https://raw.githubusercontent.com/skwp/dotfiles/master/install.sh \`"

**Always be sure to run `rake update` after pulling to ensure plugins are updated**

## What is YADR?

**YADR is an opinionated dotfile repo that will make your heart sing**

  * The best bits of all the top dotfile repos, vim and zsh plugins curated in one place, into a simple and cohesive way of working.
  * More than 90 vim plugins, all under one roof, working together, each plugin researched and configured to be at its best, often with better shortcut keys.
  * Many zsh plugins, starting with the wonderful Prezto base, and adding a few niceties on top.
  * All things are vimized: irb, postgres command line, etc.

## Mailing List

Got questions, concerns, want to hear announcements? Join the [Google Group](https://groups.google.com/forum/#!forum/yadr-users)

Please use GitHub Issues for pull requests or bug reports only.

## Screenshot

![screenshot](http://i.imgur.com/3C1Ze.png)

## Installation

To get started please run:

```bash
sh -c "`curl -fsSL https://raw.githubusercontent.com/skwp/dotfiles/master/install.sh`"
```

**Note:** YADR will automatically install all of its subcomponents. If you want to be asked
about each one, use:

```bash
sh -c "`curl -fsSL https://raw.githubusercontent.com/skwp/dotfiles/master/install.sh`" -s ask
```

## Wait, you're not done! Do this:

#### Install iTerm Solarized Colors
YADR will install Solarized colorschemes into your iTerm. Go to Profiles => Colors => Load Presets to pick Solarized Dark.

#### Remap caps-lock to escape with [Seil](https://pqrs.org/osx/karabiner/seil.html.en)
The escape key is the single most used key in vim.  Old keyboards used to have Escape where Tab is today. Apple keyboards are the worst with their tiny Esc keys. But all this is fixed by remapping Caps to Escape.  If you're hitting a small target in the corner, you are slowing yourself down considerably, and probably damaging your hands with repetitive strain injuries.

#### Set up a system wide hotkey for iTerm (Keys=>Hotkey)
Recommended Cmd-Escape, which is really Cmd-Capslock.

#### In iTerm, uncheck "Use Lion-style full screen" on General
This will give you fast full screen windows that are switchable without switching to spaces.

#### in MacVim, uncheck Prefer native fullscreen under Advanced settings
Same as iTerm. The Lion style spaces navigation slows everything down for no reason.

## If you want to run vim in terminal

* Make sure you install Solarized colorscheme in your terminal!
* If you don't want to use solarized terminal, then make sure you do this:

      let g:yadr_using_unsolarized_terminal = 1
      # in ~/.vimrc.before

* If you want to use an alternate colorcheme like Gruvbox, then in your `~/.vimrc.after` do:

      let g:yadr_disable_solarized_enhancements = 1
      colorscheme base16-twilight

### Upgrading

Upgrading is easy.

```bash
cd ~/.yadr
git pull --rebase
rake update
```

## What's included, and how to customize?

Read on to learn what YADR provides!

### [Homebrew](http://mxcl.github.com/homebrew/)

Homebrew is _the missing package manager for OSX_. Installed automatically.

We automatically install a few useful packages including ctags, git, macvim, hub, and the silver searcher ('ag')
Note that our autocomplete plugin requires a MacVim that supports Lua. The installer knows how to install it, but if you had one installed before, you may need to manually remove your old MacVim.

### ZSH

Think of Zsh as a more awesome bash without having to learn anything new.
Automatic spell correction for your commands, syntax highlighting, and more.
We've also provided lots of enhancements:

* Vim mode and bash style `Ctrl-R` for reverse history finder
* `Ctrl-x,Ctrl-l` to insert output of last command
* Fuzzy matching - if you mistype a directory name, tab completion will fix it
* [fasd](https://github.com/clvv/fasd) integration - hit `z` and partial match for recently used directory. Tab completion enabled.
* [Prezto - the power behind YADR's zsh](http://github.com/sorin-ionescu/prezto)
* [How to add your own ZSH theme](doc/zsh/themes.md)

### Aliases

Lots of things we do every day are done with two or three character
mnemonic aliases. Please feel free to edit them:

    ae # alias edit
    ar # alias reload


### Git Customizations:

YADR will take over your `~/.gitconfig`, so if you want to store your usernames, please put them into `~/.gitconfig.user`

It is recommended to use this file to set your user info. Alternately, you can set the appropriate environment variables in your `~/.secrets`.

  * `git l` or `gl`- a much more usable git log
  * `git b` or `gb`- a list of branches with summary of last commit
  * `git r` - a list of remotes with info
  * `git t` or `gt`- a list of tags with info
  * `git nb` or `gnb`- a (n)ew (b)ranch - like checkout -b
  * `git cp` or `gcp`- cherry-pick -x (showing what was cherrypicked)
  * `git simple` - a clean format for creating changelogs
  * `git recent-branches` - if you forgot what you've been working on
  * `git unstage` / `guns` (remove from index) and `git uncommit` / `gunc` (revert to the time prior to the last commit - dangerous if already pushed) aliases
  * Some sensible default configs, such as improving merge messages, push only pushes the current branch, removing status hints, and using mnemonic prefixes in diff: (i)ndex, (w)ork tree, (c)ommit and (o)bject
  * Slightly improved colors for diff
  * `gdmb` (g)it (d)elete (m)erged (b)ranches - Deletes all branches already merged on current branch

### RubyGems

A .gemrc is included. Never again type `gem install whatever --no-ri --no-rdoc`. `--no-ri --no-rdoc` is done by default.

### Tmux configuration

`tmux.conf` provides some sane defaults for tmux on Mac OS like a powerful status bar and vim keybindings.
You can customize the configuration in `~/.tmux.conf.user`.

### Vimization of everything

The provided inputrc and editrc will turn your various command line tools like mysql and irb into vim prompts. There's
also an included Ctrl-R reverse history search feature in editrc, very useful in irb, postgres command line, and etc.

### Github Issues: [ghi gem](https://github.com/stephencelis/ghi)

We include the `ghi` command. Try `ghi list` and have fun managing issues from command line!


## Vim - What's included?

 * [Navigation - NERDTree, EasyMotion, CtrlP and more](doc/vim/navigation.md)
 * [Text Objects - manipulate ruby blocks, and more](doc/vim/textobjects.md)
 * [Code manipulation - rails support, comments, snippets, highlighting](doc/vim/coding.md)
 * [Utils - indents, paste buffer management, lots more](doc/vim/utils.md)
 * [General enhancements that don't add new commands](doc/vim/enhancements.md)

A list of some of the most useful commands that YADR provides in vim are
included below. This is not a comprehensive list. To get deeper knowledge,
practice a few of these every day, and then start looking into the lists
of plugins above to learn more.

#### Navigation

 * `,z` - go to previous buffer (:bp)
 * `,x` - go to next buffer (:bn)
 * `Cmd-j` and `Cmd-k` to move up and down roughly by functions (`Alt` in Linux)
 * `Ctrl-o` - Old cursor position - this is a standard mapping but very useful, so included here
 * `Ctrl-i` - opposite of Ctrl-O (again, this is standard)

#### Search/Code Navigation

 * `,f` - instantly Find definition of class (must have exuberant ctags installed)
 * `,F` - same as `,f` but in a vertical split
 * `,gf` or `Ctrl-f` - same as vim normal gf (go to file), but in a vertical split (works with file.rb:123 line numbers also)
 * `gF` - standard vim mapping, here for completeness (go to file at line number)
 * `K` - Search the current word under the cursor and show results in quickfix window
 * `,K` - Grep the current word up to next exclamation point (useful for ruby foo! methods)
 * `Cmd-*` - highlight all occurrences of current word (similar to regular `*` except doesn't move)
 * `,hl` - toggle search highlight on and off
 * `,gg` or `,ag` - Grep command line, type between quotes. Uses Ag Silver Searcher.
 * After searching with `,gg` you can navigate the results with `Ctrl-x` and `Ctrl-z` (or standard vim `:cn` and `:cp`)
 * `,gd` - Grep def (greps for 'def [function name]') when cursor is over the function name
 * `,gcf` - Grep Current File to find references to the current file
 * `//` - clear the search
 * `,,w` (alias `,<esc>`) or `,,b` (alias `,<shift-esc>`) - EasyMotion, a vimperator style tool that highlights jump-points on the screen and lets you type to get there.
 * `,mc` - mark this word for MultiCursor (like sublime). Use `Ctrl-n` (next), `Ctrl-p` (prev), `Ctrl-x`(skip) to add more cursors, then do normal vim things like edit the word.
 * `gK` - Opens the documentation for the word under the cursor.
 * Spacebar - Sneak - type two characters to move there in a line. Kind of like vim's `f` but more accurate.
 * `:Gsearch foo` - global search, then do your normal `%s/search/replace/g` and follow up with `:Greplace` to replace across all files. When done use `:wall` to write all the files.
 

#### File Navigation

 * `,t` - CtrlP fuzzy file selector
 * `,b` - CtrlP buffer selector - great for jumping to a file you already have open
 * `Cmd-Shift-M` - jump to method - CtrlP tag search within current buffer
 * `,jm` jump to models. Other `,j` mappings: `,jc` for controllers, `,jh` for helpers, etc. If you think of a concept and a letter, we've got you covered.
 * `Cmd-Shift-N` - NERDTree toggle (`Alt` in Linux)
 * `Ctrl-\` - Show current file in NERDTree
 * `Cmd-Shift-P` - Clear CtrlP cache

#### Better keystrokes for common editing commands

 * Ctrl-Space to autocomplete. Tab for snipmate snippets.
 * `,#` `,"` `,'` `,]` `,)` `,}` to surround a word in these common wrappers. the # does #{ruby interpolation}. works in visual mode (thanks @cj). Normally these are done with something like `ysw#`
 * `Cmd-'`, `Cmd-"`, `Cmd-]`, `Cmd-)`, etc to change content inside those surrounding marks. You don't have to be inside them (`Alt` in Linux)
 * `,.` to go to last edit location (same as `'.`) because the apostrophe is hard on the pinky
 * `,ci` to change inside any set of quotes/brackets/etc

#### Tabs, Windows, Splits

 * Use `Cmd-1` thru `Cmd-9` to switch to a specific tab number (like iTerm and Chrome) - and tabs have been set up to show numbers (`Alt` in Linux)
 * `Ctrl-h,l,j,k` - to move left, right, down, up between splits. This also works between vim and tmux splits thanks to `vim-tmux-navigator`.
 * `Q` - Intelligent Window Killer. Close window `wincmd c` if there are multiple windows to same buffer, or kill the buffer `bwipeout` if this is the last window into it.
 * `vv` - vertical split (`Ctrl-w,v`)
 * `ss` - horizontal split (`Ctrl-w,s`)
 * `,qo` - open quickfix window (this is where output from Grep goes)
 * `,qc` - close quickfix

#### Utility

 * `Ctrl-p` after pasting - Use `p` to paste and `Ctrl-p` to cycle through previous pastes. Provided by YankRing.
 * `,yr` - view the yankring - a list of your previous copy commands. also you can paste and hit `ctrl-p` for cycling through previous copy commands
 * `crs`, `crc`, `cru` via abolish.vim, coerce to snake_case, camelCase, and UPPERCASE. There are more `:help abolish`
 * `:NR` - NarrowRgn - use this on a bit of selected text to create a new split with just that text. Do some work on it, then :wq it to get the results back.
 * `,ig` - toggle visual indentation guides
 * `,cf` - Copy Filename of current file (full path) into system (not vi) paste buffer
 * `,cn` - Copy Filename of current file (name only, no path)
 * `,yw` - yank a word from anywhere within the word (so you don't have to go to the beginning of it)
 * `,ow` - overwrite a word with whatever is in your yank buffer - you can be anywhere on the word. saves having to visually select it
 * `,ocf` - open changed files (stolen from @garybernhardt). open all files with git changes in splits
 * `,w` - strip trailing whitespaces
 * `sj` - split a line such as a hash {:foo => {:bar => :baz}} into a multiline hash (j = down)
 * `sk` - unsplit a link (k = up)
 * `,he` - Html Escape
 * `,hu` - Html Unescape
 * `,hp` - Html Preview (open in Safari)
 * `Cmd-Shift-A` - align things (type a character/expression to align by, works in visual mode or by itself) (`Alt` in Linux)
 * `:ColorToggle` - turn on #abc123 color highlighting (useful for css)
 * `:Gitv` - Git log browsers
 * `,hi` - show current Highlight group. if you don't like the color of something, use this, then use `hi! link [groupname] [anothergroupname]` in your vimrc.after to remap the color. You can see available colors using `:hi`
 * `,gt` - Go Tidy - tidy up your html code (works on a visual selection)
 * `:Wrap` - wrap long lines (e.g. when editing markdown files)
 * `Cmd-/` - toggle comments (usually gcc from tComment) (`Alt` in Linux)
 * `gcp` (comment a paragraph)

#### Rails & Ruby

 * `,vv` and `,cc` to switch between view and controller - these are maps to :Rcontroller and :Rview. Explore the :R<Tab> family of commands for more fun from rails.vim!
 * `,rs` and `,rl` to run rspec or a spec line in iTerm (check iTerm window for results)
 * `,ss` and `,sl` for the same using `spring rspec` which makes your Rails specs faster by caching the Rails env (must have spring gem installed)
 * vim-ruby-refactoring - try `,rem`, `,rel` to extract methods or let statements
 * `Ctrl-s` - Open related spec in a split. Similar to :A and :AV from rails.vim but is also aware of the fast_spec dir and faster to type
 * `:Bopen [gem name]` to navigate to a gem (@tpope/vim-bundler)
 * `,gcp` - Grep Current Partial to find references to the current view partial
 * `,orb` - outer ruby block. takes you one level up from nested blocks (great for rspec)

#### Vim Dev

 * `,vc` - (Vim Command) copies the command under your cursor and executes it in vim. Great for testing single line changes to vimrc.
 * `,vr` - (Vim Reload) source current file as a vim file

## Extending and overriding YADR settings

* [Debugging vim keymappings](doc/vim/keymaps.md)
* [Overriding vim settings with ~/.vimrc.after and friends](doc/vim/override.md)
* [Adding your own vim plugins](doc/vim/manage_plugins.md)

## Misc

* [Credits & Thanks](doc/credits.md)
* [Other recommended OSX productivity tools](doc/osx_tools.md)
* [Yan's Blog](http://yanpritzker.com)

### OSX Hacks

The osx file is a bash script that sets up sensible defaults for devs and power users
under osx. Read through it before running it. To use:

    bin/osx

These hacks are Lion-centric. May not work for other OS'es. My favorite mods include:

  * Ultra fast key repeat rate (now you can scroll super quick using j/k)
  * No disk image verification (downloaded files open quicker)
  * Display the ~/Library folder in finder (hidden in Lion)

### Macvim troubles with Lua?
```
brew uninstall macvim
brew remove macvim
brew cleanup
brew install macvim --custom-icons --with-override-system-vim --with-lua --with-luajit
```

### Terminal Vim troubles with Lua?
Installing terminal vim (with lua) with an RVM managed Ruby can cause the neocomplete plugin to segfault. Try uninstalling vim, then installing with system ruby:

```
brew uninstall vim
rvm system do brew install vim --with-lua
```


### [Pry](http://pry.github.com/)

Pry offers a much better out of the box IRB experience with colors, tab completion, and lots of other tricks. You can also use it
as an actual debugger by installing [pry-nav](https://github.com/nixme/pry-nav).

[Learn more about YADR's pry customizations and how to install](doc/pry.md)
