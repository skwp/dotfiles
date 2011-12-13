"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

" Use tpope's pathogen plugin to manage all other plugins
runtime bundle/tpope-vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

set number " Line numbers are good

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default

set nowrap      "dont wrap lines
set linebreak   "wrap lines at convenient points

" swapfiles are lame. we have git
set noswapfile  
set nobackup
set nowb

" Disable cursor blink
set gcr=a:blinkon0

" persistent undos - undo after you re-open the file
" but this gives warnings under command line vim
" use only in macvim
if has('gui_running')
  set undodir=~/.vim/backups
  set undofile
endif

" indent
set ai " autoindent
set si " smart indent
set smarttab

"indent settings
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set autoindent
set list listchars=tab:\ \ ,trail:·

" Prevent 'Press ENTER..' on error messages
set shortmess=atI

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

"make cmdline tab completion similar to bash
set wildmode=list:longest
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing

"display tabs and trailing spaces
set list
set listchars=tab:\ \ ,extends:>,precedes:<

set formatoptions-=o "dont continue comments when pushing o/O

"vertical/horizontal scroll off settings
set scrolloff=8
set sidescrolloff=7
set sidescroll=1

"load ftplugins and indent files
filetype plugin on
filetype indent on

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

" The current buffer can be put to the background without writing to disk;
" When a background buffer becomes current again, marks and undo-history are remembered.
" Turn this on.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

" Make it beautiful - colors and fonts
if has("gui_running")
  "tell the term has 256 colors
  set t_Co=256

  " http://ethanschoonover.com/solarized/vim-colors-solarized
  colorscheme solarized
  set background=dark

  set guitablabel=%M%t
  set lines=60
  set columns=190

  set guifont=Inconsolata:h20,Monaco:h17
else
  "dont load csapprox if we no gui support - silences an annoying warning
  let g:CSApprox_loaded = 1
endif


" automaticaly reload files changed outside of vim
set autoread

" save up to 100 marks and f1 means global marks (capital letters) are enabled
set viminfo='100,f1

" prevent auto insert mode, which is helpful when using conque
" term for running tests
autocmd WinEnter * stopinsert
