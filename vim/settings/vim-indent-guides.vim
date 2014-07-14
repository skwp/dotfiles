let g:indent_guides_guide_size = 2
let g:indent_guides_enable_on_vim_startup = 0
let g:indent_guides_auto_colors = 0
let g:indent_guides_start_level = 1
au VimEnter,Colorscheme * :hi IndentGuidesOdd ctermbg=black
au VimEnter,Colorscheme * :hi IndentGuidesEvent ctermbg=darkgrey
