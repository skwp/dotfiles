" Set the shell to bash so we inherit its path, to make sure
" we inherit its path. This affects :Rtags finding the right
" path to homebrewed ctags rather than the XCode version of ctags
"
" Use login Shell instead of interactive shell to avoid
" vimdiff suspended at startup
if has("gui_running")
  set shell=bash\ -i
else
  set shell=bash\ -l
endif
