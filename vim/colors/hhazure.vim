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
hi VertSplit               gui=underline   guifg=bg      guibg=#051525
hi StatusLine              gui=underline   guifg=fg      guibg=#051525
hi StatusLineNC            gui=underline   guifg=#2c3c45 guibg=#051525
hi LineNr                  gui=underline   guifg=#54657d guibg=#051525
hi Folded                  gui=none        guifg=#54657d guibg=bg
hi FoldColumn              gui=none        guifg=#54657d guibg=bg
" title
hi Title                   gui=underline   guifg=fg      guibg=#34455d 
" message
hi MoreMsg                 gui=underline   guifg=bg      guibg=#329858
hi Question                gui=underline   guifg=bg      guibg=#329858

hi Normal                  gui=none        guifg=#7990a4 guibg=#152535
hi NonText                 gui=underline   guifg=#1d2d30
hi NonText                                 guibg=#1d2d30

" cursor {{{1
hi WildMenu                gui=underline   guifg=bg      guibg=#99ccb5
hi Cursor                  gui=underline   guifg=bg      guibg=#99ccb5
hi IncSearch               gui=underline   guifg=bg      guibg=#99ccb5
hi CursorIM                gui=underline   guifg=fg      guibg=#006188
hi Search                  gui=underline   guifg=bg      guibg=#33669a
hi Visual                  gui=underline   guifg=bg      guibg=#667888


" message {{{1
hi ErrorMsg                gui=underline   guifg=bg      guibg=#8cdd66
hi WarningMsg              gui=underline   guifg=bg      guibg=#66cc6a
hi ModeMsg                 gui=underline   guifg=bg      guibg=#339599   


" inner {{{1
hi Ignore                  gui=none        guifg=bg      guibg=bg   
hi Todo                    gui=underline   guifg=bg      guibg=#66cc6a
hi Error                   gui=underline   guifg=fg      guibg=#884422
hi Special                 gui=none        guifg=#66bbb6 guibg=bg   
hi SpecialKey              gui=none        guifg=#6695cc guibg=bg   
hi Identifier              gui=none        guifg=#69be97 guibg=bg   
hi Constant                gui=none        guifg=#22887b guibg=bg   
hi Statement               gui=none        guifg=#74aa66 guibg=bg   
hi Comment                 gui=none        guifg=#006188 guibg=bg   
hi Underlined              gui=underline   guifg=#826699 guibg=bg   
hi Directory               gui=none        guifg=#447760 guibg=bg   
hi PreProc                 gui=none        guifg=#557767 guibg=bg   
hi Type                    gui=none        guifg=#429999 guibg=bg   


" diff {{{1
hi DiffText                gui=underline   guifg=bg      guibg=#99ffd0
hi DiffChange              gui=underline   guifg=bg      guibg=#55aa83
hi DiffDelete              gui=none        guifg=bg      guibg=#22a5aa
hi DiffAdd                 gui=underline   guifg=bg      guibg=#2ccc22


" html {{{1
hi htmlLink                gui=underline   guifg=#6696aa guibg=bg   
hi htmlBold                gui=underline   guifg=bg      guibg=#74aa66     
hi htmlBoldUnderline       gui=underline   guifg=#74aa66 guibg=bg   
hi htmlItalic              gui=underline   guifg=bg      guibg=#44ccc0
hi htmlUnderlineItalic     gui=underline   guifg=#44ccc0 guibg=bg   
hi htmlBoldItalic          gui=underline   guifg=bg      guibg=#33aa40
hi htmlBoldUnderlineItalic gui=underline   guifg=#33aa40 guibg=bg   
hi htmlUnderline           gui=underline   guifg=fg      guibg=bg   

"}}}1
" vim:set nowrap foldmethod=marker expandtab:
