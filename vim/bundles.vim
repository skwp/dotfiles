" ========================================
" Vim plugin configuration
" ========================================
"
" This file contains the list of plugin installed using neobundle plugin manager.
" Once you've updated the list of plugin, you can run neobundle update by issuing
" the command :NeoBundleInstall from within vim or directly invoking it from the
" command line with the following syntax:
" vim --noplugin -u vim/bundles.vim -N "+set hidden" "+syntax on" +NeoBundleClean! +NeoBundleInstall +qall
" Filetype off is required by neobundle
filetype off

set rtp+=~/.vim/bundle/neobundle.vim/

call neobundle#rc(expand('~/.vim/bundle/'))

" let NeoBundle manage NeoBundle (required)
NeoBundleFetch "Shougo/neobundle.vim"

" All your bundles here

" Ruby, Rails, Rake...
NeoBundle "astashov/vim-ruby-debugger"
NeoBundle "ecomba/vim-ruby-refactoring"
NeoBundle "skwp/vim-ruby-conque"
NeoBundle "tpope/vim-rails.git"
NeoBundle "tpope/vim-rake.git"
NeoBundle "tpope/vim-rvm.git"
NeoBundle "vim-ruby/vim-ruby.git"
NeoBundle "vim-scripts/Specky.git"

" Other languages
NeoBundle "briancollins/vim-jst"
NeoBundle "pangloss/vim-javascript"

" Html, Xml, Css, Markdown...
NeoBundle "aaronjensen/vim-sass-status.git"
NeoBundle "claco/jasmine.vim"
NeoBundle "digitaltoad/vim-jade.git"
NeoBundle "groenewege/vim-less.git"
NeoBundle "itspriddle/vim-jquery.git"
NeoBundle "jtratner/vim-flavored-markdown.git"
NeoBundle "kchmck/vim-coffee-script"
NeoBundle "kogakure/vim-sparkup.git"
NeoBundle "nelstrom/vim-markdown-preview"
NeoBundle "skwp/vim-html-escape"
NeoBundle "slim-template/vim-slim.git"
NeoBundle "timcharper/textile.vim.git"
NeoBundle "tpope/vim-haml"
NeoBundle "wavded/vim-stylus"

" Git related...
NeoBundle "gregsexton/gitv"
NeoBundle "mattn/gist-vim"
NeoBundle "skwp/vim-git-grep-rails-partial"
NeoBundle "tjennings/git-grep-vim"
NeoBundle "tpope/vim-fugitive"
NeoBundle "tpope/vim-git"

" General text editing improvements...
NeoBundle "AndrewRadev/splitjoin.vim"
NeoBundle "Raimondi/delimitMate"
NeoBundle "Shougo/neocomplcache.git"
NeoBundle "briandoll/change-inside-surroundings.vim.git"
NeoBundle "garbas/vim-snipmate.git"
NeoBundle "godlygeek/tabular"
NeoBundle "honza/vim-snippets"
NeoBundle "nelstrom/vim-visual-star-search"
NeoBundle "skwp/vim-easymotion"
NeoBundle "tomtom/tcomment_vim.git"
NeoBundle "tpope/vim-bundler"
NeoBundle "vim-scripts/IndexedSearch"
NeoBundle "vim-scripts/camelcasemotion.git"
NeoBundle "vim-scripts/matchit.zip.git"

" General vim improvements
NeoBundle "MarcWeber/vim-addon-mw-utils.git"
NeoBundle "bogado/file-line.git"
NeoBundle "jistr/vim-nerdtree-tabs.git"
NeoBundle "kien/ctrlp.vim"
NeoBundle "majutsushi/tagbar.git"
NeoBundle "mattn/webapi-vim.git"
NeoBundle "rking/ag.vim"
NeoBundle "scrooloose/nerdtree.git"
NeoBundle "scrooloose/syntastic.git"
NeoBundle "sjbach/lusty.git"
NeoBundle "sjl/gundo.vim"
NeoBundle "skwp/YankRing.vim"
NeoBundle "skwp/greplace.vim"
NeoBundle "skwp/vim-conque"
NeoBundle "tomtom/tlib_vim.git"
NeoBundle "tpope/vim-abolish"
NeoBundle "tpope/vim-endwise.git"
NeoBundle "tpope/vim-ragtag"
NeoBundle "tpope/vim-repeat.git"
NeoBundle "tpope/vim-surround.git"
NeoBundle "tpope/vim-unimpaired"
NeoBundle "vim-scripts/AnsiEsc.vim.git"
NeoBundle "vim-scripts/AutoTag.git"
NeoBundle "vim-scripts/lastpos.vim"
NeoBundle "vim-scripts/sudo.vim"
NeoBundle "xsunsmile/showmarks.git"

" Text objects
NeoBundle "austintaylor/vim-indentobject"
NeoBundle "bootleq/vim-textobj-rubysymbol"
NeoBundle "coderifous/textobj-word-column.vim"
NeoBundle "kana/vim-textobj-datetime"
NeoBundle "kana/vim-textobj-entire"
NeoBundle "kana/vim-textobj-function"
NeoBundle "kana/vim-textobj-user"
NeoBundle "lucapette/vim-textobj-underscore"
NeoBundle "nathanaelkane/vim-indent-guides"
NeoBundle "nelstrom/vim-textobj-rubyblock"
NeoBundle "thinca/vim-textobj-function-javascript"
NeoBundle "vim-scripts/argtextobj.vim"

" Cosmetics, color scheme, Powerline...
NeoBundle "chrisbra/color_highlight.git"
NeoBundle "skwp/vim-colors-solarized"
NeoBundle "skwp/vim-powerline.git"
NeoBundle "vim-scripts/TagHighlight.git"
NeoBundle "itspriddle/vim-jquery.git"
NeoBundle "slim-template/vim-slim.git"
NeoBundle "bogado/file-line.git"
NeoBundle "tpope/vim-rvm.git"
NeoBundle "nelstrom/vim-visual-star-search"

" Customization
" The plugins listed in ~/.vim/.bundles.local will be added here to
" allow the user to add vim plugins to yadr without the need for a fork.
if filereadable(expand("~/.yadr/vim/.bundles.local"))
  source ~/.yadr/vim/.bundles.local
endif

"Filetype plugin indent on is required by NeoBundle
filetype plugin indent on

" Installation check.
NeoBundleCheck
