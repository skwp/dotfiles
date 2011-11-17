" Vim color file {{{1
"  Maintainer: hira@users.sourceforge.jp
" Last Change: 2003/11/29 (Sat) 13:28:25.
"     Version: 1.2
" This color scheme uses a dark background.

" Happy Hacking color scheme {{{1
set background=dark
hi clear
if exists("syntax_on")
   syntax reset
endif
let colors_name       = expand("<sfile>:t:r")
let html_my_rendering = 1


" frame & title & message (theme) {{{1
hi LineNr                  gui=underline   guifg=#757164 guibg=#1c1910
hi Folded                  gui=none        guifg=#757164 guibg=bg
hi FoldColumn              gui=none        guifg=#757164 guibg=bg
" title
hi Title                   gui=underline   guifg=fg      guibg=#555144 
" message
hi MoreMsg                 gui=underline   guifg=bg      guibg=#986c32
hi Question                gui=underline   guifg=bg      guibg=#986c32

hi NonText                 gui=underline   guifg=#2c2920 guibg=#2c2920
hi VertSplit               gui=underline   guifg=bg      guibg=#1c1910
hi StatusLine              gui=underline   guifg=fg      guibg=#1c1910
hi StatusLineNC            gui=underline   guifg=#3c382c guibg=#1c1910

" cursor {{{1
hi WildMenu                gui=underline   guifg=bg      guibg=#ccbf99
hi Cursor                  gui=underline   guifg=bg      guibg=#ccbf99
hi IncSearch               gui=underline   guifg=bg      guibg=#ccbf99
hi CursorIM                gui=underline   guifg=fg      guibg=#458800
hi Search                  gui=underline   guifg=bg      guibg=#997e33
hi Visual                  gui=underline   guifg=bg      guibg=#887f66


" message {{{1
hi ErrorMsg                gui=underline   guifg=bg      guibg=#dd6674
hi WarningMsg              gui=underline   guifg=bg      guibg=#cc7e66
hi ModeMsg                 gui=underline   guifg=bg      guibg=#819933   


"TODO
" inner {{{1
hi Normal                  gui=none        guifg=#bbae88 guibg=#332f22
hi Ignore                  gui=none        guifg=bg      guibg=bg   
hi Todo                    gui=underline   guifg=bg      guibg=#cc7e66
hi Error                   gui=underline   guifg=fg      guibg=#7e3399
hi Special                 gui=none        guifg=#afbb66 guibg=bg   
hi SpecialKey              gui=none        guifg=#81cc66 guibg=bg   
hi Identifier              gui=none        guifg=#bea869 guibg=bg   
hi Constant                gui=none        guifg=#818822 guibg=bg   
hi Statement               gui=none        guifg=#aa6667 guibg=bg   
hi Comment                 gui=none        guifg=#458800 guibg=bg   
hi Underlined              gui=underline   guifg=#66998c guibg=bg   
hi Directory               gui=none        guifg=#776a44 guibg=bg   
hi PreProc                 gui=none        guifg=#776e55 guibg=bg   
hi Type                    gui=none        guifg=#9fbb22 guibg=bg   


" diff {{{1
hi DiffText                gui=underline   guifg=bg      guibg=#ffe499
hi DiffChange              gui=underline   guifg=bg      guibg=#aa9455
hi DiffDelete              gui=none        guifg=bg      guibg=#89aa22
hi DiffAdd                 gui=underline   guifg=bg      guibg=#cc3a22


" html {{{1
hi htmlLink                gui=underline   guifg=#89aa66 guibg=bg   
hi htmlBold                gui=underline   guifg=bg      guibg=#aa6667     
hi htmlBoldUnderline       gui=underline   guifg=#aa6667 guibg=bg   
hi htmlItalic              gui=underline   guifg=bg      guibg=#bccc44
hi htmlUnderlineItalic     gui=underline   guifg=#bccc44 guibg=bg   
hi htmlBoldItalic          gui=underline   guifg=bg      guibg=#aa5833
hi htmlBoldUnderlineItalic gui=underline   guifg=#aa5833 guibg=bg   
hi htmlUnderline           gui=underline   guifg=fg      guibg=bg   

"}}}1
" vim:set nowrap foldmethod=marker expandtab:
