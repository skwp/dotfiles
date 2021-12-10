" ========================================
" Vim-plug configuration
" ========================================
"
" This file contains the list of plugin installed using VimPlug  plugin manager.
" Once you've updated the list of plugin, you can run vundle update by issuing
" the command :PlugInstall from within vim or directly invoking it from the

set rtp+=~/.vim/plugs/

call plug#begin('~/.vim/plugged')

runtime ruby.plugged
runtime languages.plugged
runtime git.plugged
runtime appearance.plugged
runtime textobjects.plugged
runtime search.plugged
runtime project.plugged
runtime vim-improvements.plugged

call plug#end()
