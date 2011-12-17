" persistent undos - undo after you re-open the file
" but this gives warnings under command line vim
" use only in macvim
if has('gui_running')
  set undodir=~/.vim/backups
  set undofile
endif
