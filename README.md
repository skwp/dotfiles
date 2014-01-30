     _     _           _
    | |   | |         | |
    | |___| |_____  __| | ____
    |_____  (____ |/ _  |/ ___)
     _____| / ___ ( (_| | |
    (_______\_____|\____|_|

    # Yet Another Dotfile Repo v1.1
    # Now with Prezto and Vundle!

    sh -c "`curl -fsSL https://raw.github.com/skwp/dotfiles/master/install.sh`"

**Always be sure to run `rake update` after pulling to ensure plugins are updated**

## What is YADR?

**YADR is an opinionated dotfile repo that will make your heart sing**

  * YADR takes a curated set of the best of the best in plugins, dotfile repos and ties them all together into a cohesive system.
  * More than 90 vim plugins, all under one roof, working together.
  * Each plugin is researched and configured to be at its best and to work with other plugins. Often times, better keymaps are provided. See `.yadr/vim/settings` and `.yadr/zsh/`for some examples.
  * All common shell and vim commands should be two and three character mnemonic aliases - less keystrokes, RSI reduction
  * All things are vimized: irb, postres command line, etc.
  * Optimized support for Solarized color scheme only, everything guaranteed to Look Good. Your eyes will thank you.

## Mailing List

Got questions, concerns, want to hear announcements? Join the [Google Group](https://groups.google.com/forum/#!forum/yadr-users)

Please use GitHub Issues for pull requests or bug reports only.

## Screenshot

![screenshot](http://i.imgur.com/3C1Ze.png)

## Installation

To get started please run:

```bash
sh -c "`curl -fsSL https://raw.github.com/skwp/dotfiles/master/install.sh`"
```

**Note:** YADR will automatically install all of its subcomponents. If you want to be asked
about each one, use:
```bash
sh -c "`curl -fsSL https://raw.github.com/skwp/dotfiles/master/install.sh`" -s ask
```

* Install iTerm Solarized Colors - YADR will install Solarized colorschemes into your iTerm. Go to Profiles => Colors => Load Presets to pick Solarized Dark.
* [Remap caps-lock to escape with PCKeyboardHack](http://pqrs.org/macosx/keyremap4macbook/pckeyboardhack.html) - The escape key is the single most used key in vim.  Old keyboards used to have Escape where Tab is today. Apple keyboards are the worst with their tiny Esc keys. But all this is fixed by remapping Caps to Escape.  If you're hitting a small target in the corner, you are slowing yourself down considerably, and probably damaging your hands with repetitive strain injuries.
* Remap your Alfred or Spotlight to `Ctrl-Cmd-Space`, so that you can use `Cmd-Space` to autocomplete in vim. This is much more friendly for your fingers than `Ctrl-n`.

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

We automatically install a few useful packages including ctags, git, and hub, and the silver searcher ('ag')
You can install macvim from brew as well, or download it from their website.

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

Lots of things I do every day are done with two or three character
mnemonic aliases. Please feel free to edit them:

    ae # alias edit
    ar # alias reload


### [Pry](http://pry.github.com/)

Pry offers a much better out of the box IRB experience with colors, tab completion, and lots of other tricks. You can also use it
as an actual debugger by installing [pry-nav](https://github.com/nixme/pry-nav).

[Learn more about YADR's pry customizations and how to install](doc/pry.md)

### Git Customizations:

YADR will take over your `~/.gitconfig`, so if you want to store your usernames, please put them into `~/.gitconfig.user`

It is recommended to use this file to set your user info. Alternately, you can set the appropriate environment variables in your `~/.secrets`.

  * `git l` or `gl`- a much more usable git log
  * `git b` or `gb`- a list of branches with summary of last commit
  * `git r` - a list of remotes with info
  * `git t` or `gt`- a list of tags with info
  * `git nb` or `gnb`- a (n)ew (b)ranch - like checkout -b
  * `git cp` or `gcp`- cherry-pick -x (showing what was cherrypicked)
  * `git changelog` - a nice format for creating changelogs
  * `git recent-branches` - if you forgot what you've been working on
  * `git unstage` / `guns` (remove from index) and `git uncommit` / `gunc` (revert to the time prior to the last commit - dangerous if already pushed) aliases
  * Some sensible default configs, such as improving merge messages, push only pushes the current branch, removing status hints, and using mnemonic prefixes in diff: (i)ndex, (w)ork tree, (c)ommit and (o)bject
  * Slightly improved colors for diff

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
 * `Cmd-j` and `Cmd-k` to move up and down roughly by functions
 * `Ctrl-o` - Old cursor position - this is a standard mapping but very useful, so included here
 * `Ctrl-i` - opposite of Ctrl-O (again, this is standard)

#### Rails & Ruby

 * vim-ruby-refactoring - try `,rem`, `,rel` to extract methods or let statements
 * `,vv` and `,cc` to switch between view and controller - these are maps to :Rcontroller and :Rview. Explore the :R<Tab> family of commands for more fun from rails.vim!
 * `,rs` and `,rl` to run rspec or a spec line in iTerm (check iTerm window for results)
 * `,ss` and `,sl` for the same using `spring rspec` which makes your Rails specs faster by caching the Rails env (must have spring gem installed)

#### Search/Code Navigation

 * `,f` - instantly Find definition of class (must have exuberant ctags installed)
 * `,F` - same as `,f` but in a vertical split
 * `,gf` or `Ctrl-f` - same as vim normal gf (go to file), but in a vertical split (works with file.rb:123 line numbers also)
 * `gF` - standard vim mapping, here for completeness (go to file at line number)
 * `K` - GitGrep the current word under the cursor and show results in quickfix window
 * `,K` - GitGrep the current word up to next exclamation point (useful for ruby foo! methods)
 * `Cmd-*` - highlight all occurrences of current word (similar to regular `*` except doesn't move)
 * `,hl` - toggle search highlight on and off
 * `,gg` - GitGrep command line, type between quotes
 * `,gd` - GitGrep def (greps for 'def [function name]') when cursor is over the function name
 * `,gcp` - GitGrep Current Partial to find references to the current view partial
 * `,gcf` - GitGrep Current File to find references to the current file
 * `,ag` - Ag - silver searcher. Alternative to GitGrep that is as fast or faster.
 * `,af` - AgFile - silver searcher for a filename
 * `//` - clear the search
 * `,T` - Tag list (list of methods in a class)
 * `Ctrl-s` - Open related spec in a split. Similar to :A and :AV from rails.vim but is also aware of the fast_spec dir and faster to type
 * `,,w` (alias `,<esc>`) or `,,b` (alias `,<shift-esc>`) - EasyMotion, a vimperator style tool that highlights jump-points on the screen and lets you type to get there.
 * `,mc` - mark this word for MultiCursor (like sublime). Use `Ctrl-n` (next), `Ctrl-p` (prev), `Ctrl-x`(skip) to add more cursors, then do normal vim things like edit the word.
 * `gK` - Opens the documentation for the word under the cursor.

#### File Navigation
 * `,t` - CtrlP fuzzy file selector
 * `,b` - CtrlP buffer selector
 * `Cmd-Shift-M` - jump to method - CtrlP tag search within current buffer
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
 * `Cmd-Shift-P` - Clear CtrlP cache
 * `:Bopen [gem name]` to navigate to a gem (@tpope/vim-bundler)
 * `Cmd-Shift-N` - NERDTree toggle
 * `Ctrl-\` - Show current file in NERDTree
 * `-` open the nerdtree in the current split, rather than popping out a project drawer (uses vim-vingar)

#### Better keystrokes for common editing commands

 * Cmd-Space to autocomplete. Tab for snipmate snippets.
 * `Cmd-k` and `Cmd-d` to type underscores and dashes (use Shift), since they are so common in code but so far away from home row
 * `Ctrl-l` to insert a => hashrocket (thanks @garybernhardt)
 * `,.` to go to last edit location (same as `'.`) because the apostrophe is hard on the pinky
 * `,ci` to change inside any set of quotes/brackets/etc
 * `,#` `,"` `,'` `,]` `,)` `,}` to surround a word in these common wrappers. the # does #{ruby interpolation}. works in visual mode (thanks @cj). Normally these are done with something like `ysw#`
 * `Cmd-'`, `Cmd-"`, `Cmd-]`, `Cmd-)`, etc to change content inside those surrounding marks. You don't have to be inside them. 

#### Tabs, Windows, Splits

 * Use `Cmd-1` thru `Cmd-9` to switch to a specific tab number (like iTerm and Chrome) - and tabs have been set up to show numbers
 * `Ctrl-h,l,j,k` - to move left, right, down, up between splits
 * `Q` - Intelligent Window Killer. Close window `wincmd c` if there are multiple windows to same buffer, or kill the buffer `bwipeout` if this is the last window into it.
 * `vv` - vertical split (`Ctrl-w,v`)
 * `ss` - horizontal split (`Ctrl-w,s`)
 * `,qo` - open quickfix window (this is where output from GitGrep goes)
 * `,qc` - close quickfix

#### Utility

 * `,orb` - outer ruby block. takes you one level up from nested blocks (great for rspec)
 * `crs`, `crc`, `cru` via abolish.vim, coerce to snake_case, camelCase, and UPPERCASE. There are more `:help abolish`
 * `:NR` - NarrowRgn - use this on a bit of selected text to create a new split with just that text. Do some work on it, then :wq it to get the results back.
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
 * `,hp` - Html Preview (open in Safari)
 * `Cmd-Shift-A` - align things (type a character/expression to align by, works in visual mode or by itself)
 * `:ColorToggle` - turn on #abc123 color highlighting (useful for css)
 * `:gitv` - Git log browsers
 * `,hi` - show current Highlight group. if you don't like the color of something, use this, then use `hi! link [groupname] [anothergroupname]` in your vimrc.after to remap the color. You can see available colors using `:hi`
 * `,yr` - view the yankring - a list of your previous copy commands. also you can paste and hit `ctrl-p` for cycling through previous copy commands
 * `,gt` - Go Tidy - tidy up your html code (works on a visual selection)
 * `Ctrl-p` after pasting - Use `p` to paste and `Ctrl-p` to cycle through previous pastes. Provided by YankRing.
 * `:Wrap` - wrap long lines (e.g. when editing markdown files).
 * `Cmd-/` - toggle comments (usually gcc from tComment)
 * `gcp` (comment a paragraph)

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

    ./osx

These hacks are Lion-centric. May not work for other OS'es. My favorite mods include:

  * Ultra fast key repeat rate (now you can scroll super quick using j/k)
  * No disk image verification (downloaded files open quicker)
  * Display the ~/Library folder in finder (hidden in Lion)


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/skwp/dotfiles/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

