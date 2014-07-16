"let g:yadr_disable_solarized_enhancements = 1
for fpath in split(globpath('~/.vim/settings', '*.vim'), '\n')
  exe 'source' fpath
endfor
