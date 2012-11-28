     _     _           _
    | |   | |         | |
    | |___| |_____  __| | ____
    |_____  (____ |/ _  |/ ___)
     _____| / ___ ( (_| | |
    (_______\_____|\____|_|

    # Yet Another Dotfile Repo v1.0
    # Now with Prezto!

    git clone https://github.com/skwp/dotfiles ~/.yadr
    cd ~/.yadr && rake install

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
  * Beautiful, easy to read and small vimrc**
  * No key overrides or custom hackery in vimrc, everything in well factored snippets in .vim/plugin/settings**
  * Much larger list of vim plugins than Janus, specifically geared to Ruby/Rails/Git development.
  * Optimized support for Solarized color scheme only, everything guaranteed to Look Good. Your eyes will thank you.
  * All plugins tested with Solarized and custom color maps provided where needed to ensure your eyes will not bleed.
  * No configuration file to maintain. YADR uses tiny ruby scripts to wrap git submodule maintenance.
  * Much cleaner vimrc that keps keymaps isolated to a plugin file (not in the main vimrc).
  * All keymaps and customization in small, easy to maintain files under .vim/plugin/settings
  * More than just vim plugins - great shell aliases, osx, and irb/pry tweaks to make you more productive.

## Screenshot
![screenshot](http://i.imgur.com/3C1Ze.png)

# Installation

Installation is automated via `rake` and the `yadr` command. To get
started please run:

```bash
git clone https://github.com/skwp/dotfiles ~/.yadr
cd ~/.yadr && rake install
```

**Note:** YADR will automatically install all of its subcomponents. If you want to be asked
about each one, use `ASK=true rake install`

### Upgrading

Upgrading is easy.

```bash
cd ~/.yadr
git pull origin master
rake update
```

# What's included, and how to customize?

Read on to learn what YADR provides!

### Public service announcement: stop abusing your hands!

[Remap caps-lock to escape with PCKeyboardHack](http://pqrs.org/macosx/keyremap4macbook/pckeyboardhack.html)

The escape key is the single most used key in vim.
Old keyboards used to have Ctrl where caps lock is today. But it's even better if you put escape there.
If you're hitting a small target in the corner, you are slowing yourself down considerably, and probably damaging your hands with repetitive strain injuries.

### [Homebrew](http://mxcl.github.com/homebrew/)

Homebrew is _the missing package manager for OSX_. Installed automatically.

We automatically install a few useful packages including ack, ctags, git, and hub
You can install macvim from brew as well, or download it from their website.

```bash
brew install ack ctags git hub macvim tmux reattach-to-user-namespace
```

### Github Issues: [ghi gem](https://github.com/stephencelis/ghi)

We include the `ghi` command. Try `ghi list` and have fun managing issues from command line!

### Ruby Debugger

This gem is optonal and not included. It's used to give you visual IDE-style debugging within vim, combined
with the vim-ruby-debugger plugin. To install:

```bash
gem install ruby-debug-ide
```

### ZSH

After a lifetime of bash, I am now using ZSH as my default shell because of its awesome globbing
and autocomplete features (the spelling fixer autocomplete is worth the money alone).

Migrating from bash to zsh is essentially pain free. The zshrc provided here
restores a few features that I felt was 'broken' including Ctrl-R reverse history search.

Lots of things I do every day are done with two or three character
mnemonic aliases. Please feel free to edit them:

    ae # alias edit
    ar # alias reload

### [Prezto](https://github.com/sorin-ionescu/prezto)

For a more complete Zsh experience we use **[Prezto](http://github.com/sorin-ionescu/prezto)**.
Prezto is included as a submodule.

### Adding your own ZSH theme

If you want to add your own zsh theme, you can place it into ~/.zsh.prompts and it will automatically be picked up by the prompt loader.

Make sure you follow the naming convention of `prompt_[name]_setup`

```
touch ~/.zsh.prompts/prompt_mytheme_setup
```

Check out ~/.yadr/zsh/prezto-themes/prompt_skwp_setup for an example of how to write a prompt.
See also the [Prezto](https://github.com/sorin-ionescu/prezto) project for more info on themes.

### Customizing ZSH & Picking a theme

If you want to customize your zsh experience, yadr provides two hooks via ~/.zsh.after/ and ~/.zsh.before/ directories.
In these directories, you can place files to customize things that load before and after other zsh customizations that come from ~/.yadr/zsh/*

For example, to override the theme, you can do something like this:
```
echo "prompt skwp" > ~/.zsh.after/prompt.zsh
```

Next time you load your shell, this file will be read and your prompt will be the skwp prompt. Use `prompt -l` to see the available prompts.

### Included ZSH Customizations

 * Vim mode
 * Bash style ctrl-R for reverse history finder
 * Ctrl-x,Ctrl-l to insert output of last command
 * Fuzzy matching - if you mistype a directory name, tab completion will fix it
 * [fasd](https://github.com/clvv/fasd) integration - hit `z` and partial match for recently used directory. Tab completion enabled.
 * Syntax highlighting as you type commands
 * Lots more!

### [Pry](http://pry.github.com/) 
Pry offers a much better out of the box IRB experience with colors, tab completion, and lots of other tricks. You can also use it
as an actual debugger on MRI 1.9.2+ by installing [pry-debugger](https://github.com/nixme/pry-debugger).

[Learn more about YADR's pry customizations and how to install](https://github.com/skwp/dotfiles/blob/master/README-pry.md)

### Git User Info

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

### RubyGems

A .gemrc is included. Never again type `gem install whatever --no-ri --no-rdoc`. `--no-ri --no-rdoc` is done by default.

### Vimization of everything

The provided inputrc and editrc will turn your various command line tools like mysql and irb into vim prompts. There's
also an included Ctrl-R reverse history search feature in editrc, very useful in irb.

### Vim Configuration

The .vimrc is well commented and broken up by settings. I encourage you
to take a look and learn some of my handy aliases, or comment them out
if you don't like them, or make your own.


### Vim Keymaps

The files in vim/plugin/settings are customizations stored on a per-plugin
basis. The main keymap is available in skwp-keymap.vim, but some of the vim
files contain key mappings as well (TODO: probably will move them out to skwp-keymap.vim)

### Debugging vim keymappings

If you are having unexpected behavior, wondering why a particular key works the way it does,
use: `:map [keycombo]` (e.g. `:map <C-\>`) to see what the key is mapped to. For bonus points, you can see where the mapping was set by using `:verbose map [keycombo]`.
If you omit the key combo, you'll get a list of all the maps. You can do the same thing with nmap, imap, vmap, etc.


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

 * `Cmd-Shift-R` to use vim-ruby-conque to run a spec file. `Cmd-Shift-L` to run from a line (individual it block), `,Cmd-Shift-R` to rerun the last run command (great for re-running specs)
 * :Rspec1 and :Rspec2 to switch between rspec versions for the vim-ruby-conque runner
 * `,vv` and `,cc` to switch between view and controller

#### Surround.vim customizations

 * in plugin/settings/surround.vim (this folder contains all my customizations)
 * the `#` key now surrounds with `#{}`, so `ysaw#` (surround around word) `#{foo}`
 * `=` surrounds with `<%= erb tag %>`; `-` for `<% this %>`. So, `yss=` or `yss-` to wrap code

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
 * `//` - clear the search
 * `,q/` -  quickfix window with last search (stolen from Steve Losh)
 * `,qa/` - quickfix Ack last search (Steve Losh)
 * `,qg/` - quickfix GitGrep last search
 * `,T` - Tag list (list of methods in a class)
 * `Ctrl-s` - Open related spec in a split. Similar to :A and :AV from rails.vim but is also aware of the fast_spec dir and faster to type
 * `,,w` (alias `,<esc>`) or `,,b` (alias `,<shift-esc>`) - EasyMotion, a vimperator style tool that highlights jump-points on the screen and lets you type to get there.

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

#### RSI-reduction

 * Cmd-Space to autocomplete. Tab for snipmate snippets.
 * `Cmd-k` and `Cmd-d` to type underscores and dashes (use Shift), since they are so common in code but so far away from home row
 * `Ctrl-l` to insert a => hashrocket (thanks @garybernhardt)
 * `,.` to go to last edit location (same as `'.`) because the apostrophe is hard on the pinky
 * `,ci` to change inside any set of quotes/brackets/etc
 * `,#` `,"` `,'` `,]` `,)` `,}` to surround a word in these common wrappers. the # does #{ruby interpolation}. works in visual mode (thanks @cj)
 * `Cmd-'`, `Cmd-"`, `Cmd-]`, `Cmd-)`, etc to change content inside those surrounding marks. You don't have to be inside them.

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

#### NERDTree Project Tree

 * `Cmd-Shift-N` - NERDTree toggle
 * `Ctrl-\` - Show current file tree

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

#### Ruby Debugger

 * Visual ruby debugger included. All keys remapped to `,d(something)` such as `,dn` for Debugger Next or `,dv` for Debugger Variables. Use `:help ruby-debugger` for more info, but keep in mind the new key maps (see vim/plugin/settings/vim-ruby-debugger.vim)

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
 * EasyMotion - hit ,<esc> (forward) or ,<Shift-Esc> (back) and watch the magic happen. Just type the letters and jump directly to your target - in the provided vimrc the keys are optimized for home row mostly. Using @skwp modified EasyMotion which uses vimperator-style two character targets.
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
 * Powerline - beautiful vim status bar. Requires patched fonts (installed from fonts/ directory)

#### Coding

 * tComment - gcc to comment a line, gcp to comment blocks, nuff said
 * sparkup - div.foo#bar - hit `ctrl-e`, expands into `<div class="foo" id="bar"/>`, and that's just the beginning
 * rails.vim - syntax highlighting, gf (goto file) enhancements, and lots more. should be required for any rails dev
 * rake.vim - like rails.vim but for non-rails projects. makes `:Rtags` and other commands just work
 * ruby.vim - lots of general enhancements for ruby dev
 * necomplcache - intelligent and fast complete as you type, and added Command-Space to select a completion (same as Ctrl-N)
 * snipMate - offers textmate-like snippet expansion + scrooloose-snippets . try hitting TAB after typing a snippet
 * jasmine.vim - support for jasmine javascript unit testing, including snippets for it, before, etc..
 * vim-javascript-syntax, vim-jquery - better highlighting
 * TagHighlight - highlights class names and method names
 * vim-coffeescript - support for coffeescript, highlighting
 * vim-stylus - support for stylus css language
 * vim-bundler - work with bundled gems
 * vim-ruby-debugger - visual IDE-style debugger. Use `:help ruby-debugger` or `:Rdebugger` and `,dn` to step

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
 * yankring - effortless sanity for pasting. every time you yank something it goes into a buffer. after hitting p to paste, use ctrl-p or ctrl-n to cycle through the paste options. great for when you accidentally overwrite your yank with a delete.
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
 * SearchComplete - tab completion in the / search window
 * syntastic - automatic syntax checking when you save the file
 * repeat - adds `.` (repeat command) support for complex commands like surround.vim. i.e. if you perform a surround and hit `.`, it will Just Work (vim by default will only repeat the last piece of the complex command)
 * endwise - automatically closes blocks (if/end)
 * autotag - automatically creates tags for fast sourcecode browsing. use ctrl-[ over a symbol name to go to its definition
 * matchit - helps with matching brackets, improves other plugins
 * sass-status - decorates your status bar with full nesting of where you are in the sass file


### Overriding vim settings

You may use `~/.vimrc.before` for settings like the __leader__ setting.
You may `~/.vimrc.after` (for those transitioning from janus) or in `~/.yadr/vim/after/.vimrc.after` for any additional overrides/settings.
If you didn't have janus before, it is recommended to just put it in `~/.yadr/vim/after` so you can better manage your overrides.


### Adding your own vim plugins

YADR comes with a dead simple plugin manager that just uses git submodules, without any fancy config files.

    yav -u https://github.com/airblade/vim-rooter

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
 * https://github.com/sorin-ionescu
 * https://github.com/nelstrom

And everything that's in the modules included in vim/bundle of course.
Please explore these people's work.


### Contributors

 * Initial Version: @skwp
 * Cleanup, auto installer: @kylewest
 * Switch from oh-my-zsh to Presto: @JeanMertz


### For more tips and tricks

Follow my blog: http://yanpritzker.com

