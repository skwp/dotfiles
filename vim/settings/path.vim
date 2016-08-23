" Set the shell to bash so we inherit its path, to make sure
" we inherit its path. This affects :Rtags finding the right
" path to homebrewed ctags rather than the XCode version of ctags
" this will cause the issue described inhttp://apple.stackexchange.com/questions/199520/suspended-tty-output-when-launching-editors-like-vim-vi-emacs-or-nano
" and this mostly happens when switching from vim pane to other tmux pane
" set shell=bash\ -i
