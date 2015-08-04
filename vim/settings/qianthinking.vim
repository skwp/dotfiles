" encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1

" share system clipboard
if has("win16") || has("win32") || has("win64")
    set clipboard=unnamedplus
else
    set clipboard=unnamed
endif

set mouse=nv "Enable mouse use in all modes
set ttyfast "Send more characters for redraws
set ttymouse=xterm2

" complete
set completeopt=menu,menuone,preview 
"set completeopt=menuone,menu,longest,preview

set pastetoggle=<F7>
set tags=./tags;~/tags
map <F10> :!ctags -R --fields=+l --extra=+q .<CR>

let g:used_javascript_libs = 'jquery'

au BufNewFile,BufRead *.mxml set filetype=mxml
au BufNewFile,BufRead *.jsp set filetype=java
au BufNewFile,BufRead *.es6 set filetype=javascript
au BufNewFile,BufRead *.as set filetype=actionscript
au BufNewFile,BufRead {Gemfile,Rakefile,Capfile,*.rake,config.ru} set ft=ruby
au BufNewFile,BufRead *.vundle set filetype=vim
au BufNewFile,BufRead *.gradle set filetype=groovy

au FileType text setlocal textwidth=78
" return previous editing position
au BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \   exe "normal! g`\"" |
            \ endif
au FileType python let python_highlight_all=1
au FileType python setlocal omnifunc=pythoncomplete#Complete

au FileType javascript setlocal ts=2 sts=2 sw=2 

au FileType ruby,eruby setlocal ts=2 sts=2 sw=2 
au FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
au FileType ruby,eruby setlocal omnifunc=rubycomplete#Complete

au FileType c,cpp setlocal  ts=2 sts=2 sw=2
au FileType c,cpp nnoremap <F6> :YcmForceCompileAndDiagnostics<CR>
au FileType cpp map <F10> :!ctags -R --c++-kinds=+pl --fields=+ialS --extra=+q .<CR>

au FileType erlang let g:erlang_completion_grep='zgrep'
au FileType erlang let g:erlang_man_extension='erl\.gz'
au FileType erlang set nofoldenable
au FileType erlang setlocal ts=4 sts=4 sw=4

au FileType java setlocal ts=4 sts=4 sw=4
au FileType java setlocal makeprg=javac\ -d\ .\ %
au Filetype java setlocal omnifunc=javacomplete#Complete

au FileType tex setlocal ts=2 sts=2 sw=2
au FileType tex setlocal iskeyword+=:

au FileType actionscript setlocal ts=4 sts=4 sw=4
au FileType actionscript setlocal omnifunc=actionscriptcomplete#CompleteAS
au FileType actionscript setlocal dictionary=dict/actionscript.dict

" Source the vimrc file after saving it
au bufwritepost .vimrc source ~/.vimrc

"CoffeeScript
"This one compiles silently and with the -b option, but shows any errors:
au BufWritePost *.coffee silent make! -b | cwindow | redraw!
au BufNewFile,BufReadPost *.coffee setl sw=2 ts=2 sts=2 expandtab

au WinEnter * setlocal cursorline
au WinLeave * setlocal nocursorline

" other simple settings
let g:user_emmet_leader_key='<C-Z>'

" input method
se noimd
se ims=1

