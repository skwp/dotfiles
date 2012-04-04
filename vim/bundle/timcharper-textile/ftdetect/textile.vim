" textile.vim
"
" Tim Harper (tim.theenchanter.com)

" Force filetype to be textile even if already set
" This will override the system ftplugin/changelog 
" set on some distros
au BufRead,BufNewFile *.textile set filetype=textile
