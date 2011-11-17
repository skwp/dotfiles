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
hi Folded                  gui=none        guifg=#855060 guibg=bg
hi FoldColumn              gui=none        guifg=#855060 guibg=bg
hi LineNr                  gui=underline   guifg=#855060 guibg=#200510
hi VertSplit               gui=underline   guifg=bg      guibg=#200510
hi StatusLine              gui=underline   guifg=fg      guibg=#200510
hi StatusLineNC            gui=underline   guifg=#3c2c31 guibg=#200510
hi NonText                 gui=underline   guifg=#3c2530
hi NonText                                 guibg=#3c2530
" title
hi Title                   gui=underline   guifg=fg      guibg=#653040 
" message
hi MoreMsg                 gui=underline   guifg=bg      guibg=#983266
hi Question                gui=underline   guifg=bg      guibg=#983266


" cursor {{{1
hi WildMenu                gui=underline   guifg=bg      guibg=#cc7990
hi Cursor                  gui=underline   guifg=bg      guibg=#cc7990
hi IncSearch               gui=underline   guifg=bg      guibg=#cc7990
hi CursorIM                gui=underline   guifg=fg      guibg=#884830
hi Search                  gui=underline   guifg=bg      guibg=#993356
hi Visual                  gui=underline   guifg=bg      guibg=#885672


" message {{{1
hi ErrorMsg                gui=underline   guifg=bg      guibg=#c666dd
hi WarningMsg              gui=underline   guifg=bg      guibg=#cc66bc
hi ModeMsg                 gui=underline   guifg=bg      guibg=#994333   


"TODO

" inner {{{1
hi Normal                  gui=none        guifg=#bb7899 guibg=#40202a
hi Ignore                  gui=none        guifg=bg      guibg=bg   
hi Todo                    gui=underline   guifg=bg      guibg=#cc568c
hi Error                   gui=underline   guifg=fg      guibg=#335699
hi Special                 gui=none        guifg=#bb6b66 guibg=bg   
hi SpecialKey              gui=none        guifg=#cca966 guibg=bg   
hi Identifier              gui=none        guifg=#be6986 guibg=bg   
hi Constant                gui=none        guifg=#882223 guibg=bg   
hi Statement               gui=none        guifg=#a466aa guibg=bg   
hi Comment                 gui=none        guifg=#884830 guibg=bg   
hi Underlined              gui=underline   guifg=#779966 guibg=bg   
hi Directory               gui=none        guifg=#774455 guibg=bg   
hi PreProc                 gui=none        guifg=#775561 guibg=bg   
hi Type                    gui=none        guifg=#aa3222 guibg=bg   


" diff {{{1
hi DiffText                gui=underline   guifg=bg      guibg=#ff99bc
hi DiffChange              gui=underline   guifg=bg      guibg=#aa5572
hi DiffDelete              gui=none        guifg=bg      guibg=#aa3822
hi DiffAdd                 gui=underline   guifg=bg      guibg=#cc22c2


" html {{{1
hi htmlLink                gui=underline   guifg=#aa8266 guibg=bg   
hi htmlBold                gui=underline   guifg=bg      guibg=#a466aa     
hi htmlBoldUnderline       gui=underline   guifg=#a466aa guibg=bg   
hi htmlItalic              gui=underline   guifg=bg      guibg=#cc4944
hi htmlUnderlineItalic     gui=underline   guifg=#cc4944 guibg=bg   
hi htmlBoldItalic          gui=underline   guifg=bg      guibg=#aa338e
hi htmlBoldUnderlineItalic gui=underline   guifg=#aa338e guibg=bg   
hi htmlUnderline           gui=underline   guifg=fg      guibg=bg   

"}}}1
" vim:set nowrap foldmethod=marker expandtab:
