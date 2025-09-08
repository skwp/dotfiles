" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" TODO: this may not be in the correct place. It is intended to allow overriding <Leader>.
" source ~/.vimrc.before if it exists.
if filereadable(expand("~/.vimrc.before"))
  source ~/.vimrc.before
endif

" ================ General Config ====================

set number                      "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set gcr=a:blinkon0              "Disable cursor blink
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
let mapleader="<Space>"

" =============== Vundle Initialization ===============
" This loads all the plugins specified in ~/.vim/vundles.vim
" Use Vundle plugin to manage all other plugins
if filereadable(expand("~/.vim/vundles.vim"))
  source ~/.vim/vundles.vim
endif
au BufNewFile,BufRead *.vundle set filetype=vim

" ================ Turn Off Swap Files ==============
set noswapfile
set nobackup
set nowb

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo') && isdirectory(expand('~').'/.vim/backups')
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

" Auto indent pasted text
nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>

filetype plugin on
filetype indent on

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

set nowrap       "Don't wrap lines
set linebreak    "Wrap lines at convenient points

" ================ Folds ============================

" set foldmethod=indent   "fold based on indent
" set nofoldenable        "dont fold by default
" set foldmethod=syntax
" set foldnestmax=10
" set nofoldenable
" FOLD KEYS
nnoremap <Space> ff
vnoremap <Leader> ff
inoremap <F9> <C-O>za
nnoremap <F9> za
onoremap <F9> <C-C>za
vnoremap <F9> zf
let g:vimwiki_folding = 'syntax'
noremap <F8> :highlight Folded ctermbg=NONE<CR>
map <Leader>1 :highlight Folded ctermbg=NONE<CR>
set foldnestmax=3
set foldlevel=2

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

" ================ Scrolling ========================

set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

" ================ Search ===========================

set incsearch       " Find the next match as we type the search
set hlsearch        " Highlight searches by default
set ignorecase      " Ignore case when searching...
set smartcase       " ...unless we type a capital

" ================ Security ==========================
set modelines=0
set nomodeline

set nolist

if has("gui_running")
  set guifont=Sonaco:h12
  " colorscheme base16-unikitty-light
endif

" Use Relative Number
set relativenumber

" Use iTerm
let g:returnApp = "iTerm"

"Remove all trailing whitespace by pressing F5
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" ================ Vim Wiki Settings ========================
" ================ OFF BY DEFAULT ========================

" let wiki = {}
" let wiki.path = "~/Dropbox/notes-main"
" let g:vimwiki_folding='expr'
" let g:markdown_syntax_conceal = 1
" let g:vimwiki_list = [wiki]
" let g:vimwiki_folding='custom'
" au FileType vimwiki nmap <leader>tt <Plug>VimwikiToggleListItem
" au FileType vimwiki vmap <leader>tt <Plug>VimwikiToggleListItem
" let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'ruby']
" let g:medieval_langs = ['python=python3', 'ruby', 'sh', 'console=bash', 'javascript=node', 'rust=rustc']
" let g:medieval_fences = [{'start': '{{<\s\+\(\S\+\)\s\+>}}', 'end': '{{<\s\+/\1\s\+>}}'}]
" let wiki.nested_syntaxes = { 'python': 'python', 'c++': 'cpp', 'ruby': 'ruby', 'javascript': 'javascript', "go": "go", "vim": "vim", "rust": "rust", "sh": "sh", "lisp": "lisp", "swift": "swift", "haskell": "haskell" }

" function! VimwikiFindIncompleteTasks()
"   lvimgrep /- \[ \]/ %:p
"   lopen
" endfunction
" 
" function! VimwikiFindAllIncompleteTasks()
"   VimwikiSearch /- \[ \]/
"   lopen
" endfunction
" 
" nmap <Leader>wa :call VimwikiFindAllIncompleteTasks()<CR>
" nmap <Leader>wx :call VimwikiFindIncompleteTasks()<CR>

" ================ Testing Shortcuts to increase speed ======================

" RSPEC
" map <Leader>t :call RunCurrentSpecFile()<CR>
" map <Space>a :! spring rspec spec/<CR>
" map <Space>rr :call RunNearestSpec()<CR>
" map <Space>k :call RunNearestSpecRaw()<CR>
" map <Space>l :call RunLastSpec()<CR>
" map <Space>ll :call RunLastSpec()<CR>
" map <Space>aa :call RunAllSpecs()<CR>

" MINITEST
map <Space>a :call RunAllSpecs()<CR>
map <Space>t :call TestFile()<CR>
map <Space>v :! rails test --verbose<CR>
map <Space>a :! rails test<CR>
map <Space>rr :call TestNearest()<CR>

" ================ Deleted or Unused Shortcuts =======================

" map <Leader>dd :Dash<CR> #
" map <Leader>c :call ChromeReloadStart()<CR>
" map <Leader>cc :call ChromeReloadStart()<CR>
" map <Leader>9 :set foldmethod=syntax<CR>
" nnoremap <Leader>ee :<C-U>EvalBlock<CR>
" map <Leader>2 :colorscheme base16-unikitty-light<CR>
" map <Leader>3 :colorscheme base16-atelier-sulphurpool-light<CR>

" ================ Custom Shortcut Keys (Leaders etc) ========================

" Set my favorite colorscheme
set bg=dark
colorscheme morning

" Remove highlighting
map <Leader>n :noh<CR>

" Suspend the vim session (fg to get back)
noremap <silent> <Space>k :st<CR>

map <Leader>v :e ~/.vimrc<CR>
map <Space>vv :vsplit ~/.vimrc<CR>
map <Space>0 :colorscheme jellybeans<CR>
" map <Leader>8 :set ft=markdown<CR>
map <Space>9 :colorscheme morning<CR>

" Auto indent entire file
" noremap <F8> gg=G<C-s>
" inoremap <F8> gg=G<C-s>

" Enter focus mode in active pane
map <Space>g :Goyo<CR>

" map <Space>cn :e ~/Dropbox/notes/coding-notes.txt<cr>

" map <Space>mt :MarkedToggle!<cr>
" map <Space>mo :MarkedOpen!<cr>

" Trying to speed up vim
let g:loaded_matchparen=1
set nolist
set nonumber
set lazyredraw
set ttyfast

so ~/.yadr/vim/settings.vim
