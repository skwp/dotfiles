" Vim color file
" Maintainer:   Gerald S. Williams
" Last Change:  2003 Apr 17

" This is very reminiscent of a seashell. Good contrast, yet not too hard on
" the eyes. This is something of a cross between zellner and peachpuff, if
" such a thing is possible...
"
" Only values that differ from defaults are specified.

set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "seashell"

hi Normal guibg=seashell ctermbg=Gray ctermfg=Black
hi NonText guibg=LavenderBlush guifg=Gray30
hi LineNr guibg=LavenderBlush guifg=Gray30
hi DiffDelete guibg=LightRed guifg=Black ctermbg=DarkRed ctermfg=White
hi DiffAdd guibg=LightGreen ctermbg=DarkGreen ctermfg=White
hi DiffChange guibg=Gray90 ctermbg=DarkCyan ctermfg=White
hi DiffText gui=NONE guibg=LightCyan2 ctermbg=DarkCyan ctermfg=Yellow
hi Comment guifg=MediumBlue
hi Constant guifg=DeepPink
hi PreProc guifg=DarkMagenta
hi StatusLine guibg=White guifg=DarkSeaGreen cterm=None ctermfg=White ctermbg=DarkGreen
hi StatusLineNC gui=None guibg=Gray
hi VertSplit gui=None guibg=Gray
hi Identifier guifg=#006f6f
hi Statement ctermfg=DarkRed
