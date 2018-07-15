if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * :PlugInstall --sync
endif

let plugdir = '~/.vim/plugins'
call plug#begin('~/.vim/plugged')
for fpath in split(globpath(plugdir, '*.plug'), '\n')
  exe 'source' fpath
endfor
call plug#end()
