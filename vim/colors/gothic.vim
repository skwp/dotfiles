" Vim color file
" Maintainer:	Stefano deFlorian - \Goth\ <stefano@junglebit.net>
" Last Change:	2003 Dec 9
" Light - Dark :-)
" optimized for TFT panels

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
"colorscheme default
let g:colors_name = "gothic"

" hardcoded colors :

" GUI
highlight Normal     guifg=#efefef	guibg=#000000
highlight Cursor     guifg=#000000	guibg=#efefef	gui=NONE
highlight Search     guifg=#ffff60	guibg=#0000ff	gui=NONE
highlight Visual     guifg=Grey25			gui=NONE
highlight Special    guifg=Orange
highlight Comment    guifg=#3030ff
highlight StatusLine guifg=blue		guibg=white
highlight Statement  guifg=#ffff60			gui=NONE
highlight PreProc    guifg=#a0e0a0
highlight Identifier guifg=#00ffff
highlight Constant   guifg=#a0a0a0
highlight Type       guifg=#a0a0ff			gui=NONE

" Console
highlight Normal     ctermfg=LightGrey	ctermbg=Black
highlight Cursor     ctermfg=Black	ctermbg=LightGrey	cterm=NONE
highlight Search     ctermfg=Yellow	ctermbg=Blue		cterm=NONE
highlight Visual						cterm=reverse
highlight Special    ctermfg=Brown
highlight Comment    ctermfg=Blue
highlight StatusLine ctermfg=blue	ctermbg=white
highlight Identifier ctermfg=Cyan
highlight Statement  ctermfg=Yellow				cterm=NONE
highlight Constant   ctermfg=Grey				cterm=NONE
highlight Type       ctermfg=LightBlue				cterm=NONE
