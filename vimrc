" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" TODO: this may not be in the correct place. It is intended to allow overriding <Leader>.
" source ~/.vimrc.before if it exists.
if filereadable(expand("~/.vimrc.before"))
  source ~/.vimrc.before
endif
" ================ General Config ====================

set rnu!                      "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set visualbell                  "No sounds
set autoread                    "Reload files changed outside vim

" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

"turn on syntax highlighting
syntax on

" Change leader to a comma because the backslash is too far away
" That means all \x commands turn into ,x
" The mapleader has to be set before vundle starts loading all 
" the plugins.
let mapleader=","

" =============== Vundle Initialization ===============
" This loads all the plugins specified in ~/.vim/vundles.vim
" Use Vundle plugin to manage all other plugins
if filereadable(expand("~/.vim/vundles.vim"))
  source ~/.vim/vundles.vim
endif

" ================ meteor mustche settings =============
au BufReadPost *.hbs set filetype=html.mustache syntax=html.mustache
" ================ Turn Off Swap Files ==============

set noswapfile
set nobackup
set nowb

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ================ Indentation ======================

set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab

filetype plugin on
filetype indent on

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

set nowrap       "Don't wrap lines
set linebreak    "Wrap lines at convenient points

" ================ Folds ============================

set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

" ================ Completion =======================

set wildmode=list:longest
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*DS_Store*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

set textwidth=80
"================= handlebar / mustache | for syntastic
let syntastic_mode_map = { 'passive_filetypes': ['html'] }

"==================== Tlist for ctags navigation and other golang things===========
au BufRead,BufNewFile *.go setlocal set softtabstop=4 shiftwidth=4 tabstop=4
let g:rails_ctags_arguments = ['--languages=ruby']
let tlist_Ctags_Cmd = '/usr/local/bin/ctags'
let Tlist_Use_Right_Window = 1

let g:tagbar_type_go = { \ 'ctagstype' : 'Go', \ 'kinds'     : [ \ 'p:package',
      \ 'i:imports:1', \ 'c:constants', \ 'v:variables', \ 't:types', \
'n:interfaces', \ 'w:fields', \ 'e:embedded', \ 'm:methods', \ 'r:constructor',
      \ 'f:functions' \ ], \ 'sro' : '.', \ 'kind2scope' : { \ 't' : 'ctype', \
'n' : 'ntype' \ }, \ 'scope2kind' : { \ 'ctype' : 't', \ 'ntype' : 'n' \ }, \
'ctagsbin'  : 'gotags', \ 'ctagsargs' : '-sort -silent' }

nmap <leader> :TagbarToggle<CR>
" ================ Scrolling ========================
au BufNewFile,BufRead *.es6 set filetype=javascript
au FileType javascript set dictionary+=$HOME/.vim/dict/node.dict


"========================================================================

set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

set shell=zsh
" ================ Search ===========================

set incsearch       " Find the next match as we type the search
set hlsearch        " Highlight searches by default
set ignorecase      " Ignore case when searching...
set smartcase       " ...unless we type a capital

" ====================== Go  ========================

nnoremap <leader>ct :CtrlPTag<cr>

let g:SuperTabDefaultCompletionType = "context"

set foldmethod=syntax
set foldnestmax=10
set nofoldenable
set foldlevel=0
set guifont=Source\ Code\ Pro:h17 " Set default font
" ================ Custom Settings ========================
so ~/.yadr/vim/settings.vim
