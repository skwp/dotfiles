" ================ Search Settings  =================

set incsearch       " Find the next match as we type the search
set hlsearch        " Hilight searches by default
set viminfo='100,f1 " Save up to 100 marks, enable capital marks
set ignorecase      " Ignore case when searching...
set smartcase       " ...unless we type a capital
set wrapscan        " Search wrap the file

" Using Perl/Python regex style by default when searching
nnoremap / /\v
vnoremap / /\v

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz
nnoremap <c-o> <c-o>zz
