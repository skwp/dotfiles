" ========================================
" Vim plugin configuration
" ========================================
"
" This file contains the list of plugin installed using vim-plug plugin manager.
" Once you've updated the list of plugin, you can run plugin update by issuing
" the command :PlugInstall from within vim or directly invoking it from the
" command line with the following syntax:
" vim --noplugin -u vim/plugins.d/main.vim -N "+set hidden" "+syntax on" +PlugClean! +PlugInstall +qall

if empty(glob('~/.vim' . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source %
endif

set rtp+=~/.vim/plugins.d/ "Submodules

" Directory for plugins
call plug#begin('~/.vim/plugged')

" YADR's plugins are split up by category into smaller files
" This reduces churn and makes it easier to fork. See
" ~/.vim/plugged/ to edit them:
runtime ruby.bundles
runtime languages.bundles
runtime git.bundles
runtime appearance.bundles
runtime textobjects.bundles
runtime search.bundles
runtime project.bundles
runtime vim-improvements.bundles

" The plugins listed in ~/.vim/.local.bundles will be added here to
" allow the user to add vim plugins to yadr without the need for a fork.
if filereadable(expand("~/.yadr/vim/.local.bundles"))
  source ~/.yadr/vim/.local.bundles
endif

" All of your Plugins must be added before the following line
call plug#end()            " required
