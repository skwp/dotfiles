require 'fileutils'

module Plug
  def self.update_vim_pluggins
    system "vim --noplugin -u #{ENV['HOME']}/.vim/vim-plug.vim -N \"+set hidden\" \"+syntax on\" \"+let g:session_autosave = 'no'\" +PlugClean! +PlugInstall +qall"
  end
end
