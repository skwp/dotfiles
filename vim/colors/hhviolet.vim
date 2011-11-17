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
hi LineNr                  gui=underline   guifg=#686475 guibg=#13101c
hi Folded                  gui=none        guifg=#686475 guibg=bg
hi FoldColumn              gui=none        guifg=#686475 guibg=bg
" title
hi Title                   gui=underline   guifg=fg      guibg=#484455 
" message
hi MoreMsg                 gui=underline   guifg=bg      guibg=#373298
hi Question                gui=underline   guifg=bg      guibg=#373298

hi NonText                 gui=underline   guifg=#23202c guibg=#23202c
hi VertSplit               gui=underline   guifg=bg      guibg=#13101c
hi StatusLine              gui=underline   guifg=fg      guibg=#13101c
hi StatusLineNC            gui=underline   guifg=#302c3c guibg=#13101c

" cursor {{{1
hi WildMenu                gui=underline   guifg=bg      guibg=#a499cc
hi Cursor                  gui=underline   guifg=bg      guibg=#a499cc
hi IncSearch               gui=underline   guifg=bg      guibg=#a499cc
hi CursorIM                gui=underline   guifg=fg      guibg=#662088
hi Search                  gui=underline   guifg=bg      guibg=#493399
hi Visual                  gui=underline   guifg=bg      guibg=#6d6688


" message {{{1
hi ErrorMsg                gui=underline   guifg=bg      guibg=#66b2dd
hi WarningMsg              gui=underline   guifg=bg      guibg=#6683cc
hi ModeMsg                 gui=underline   guifg=bg      guibg=#7c3399   


"TODO
" inner {{{1
hi Normal                  gui=none        guifg=#9388bb guibg=#262233
hi Ignore                  gui=none        guifg=bg      guibg=bg   
hi Todo                    gui=underline   guifg=bg      guibg=#6683cc
hi Error                   gui=underline   guifg=fg      guibg=#335544
hi Special                 gui=none        guifg=#9b66bb guibg=bg   
hi SpecialKey              gui=none        guifg=#cc66b6 guibg=bg   
hi Identifier              gui=none        guifg=#7c69be guibg=bg   
hi Constant                gui=none        guifg=#774499 guibg=bg   
hi Statement               gui=none        guifg=#668aaa guibg=bg   
hi Comment                 gui=none        guifg=#662088 guibg=bg   
hi Underlined              gui=underline   guifg=#997166 guibg=bg   
hi Directory               gui=none        guifg=#4f4477 guibg=bg   
hi PreProc                 gui=none        guifg=#5c5577 guibg=bg   
hi Type                    gui=none        guifg=#7733cc guibg=bg   


" diff {{{1
hi DiffText                gui=underline   guifg=bg      guibg=#af99ff
hi DiffChange              gui=underline   guifg=bg      guibg=#6855aa
hi DiffDelete              gui=none        guifg=bg      guibg=#8422aa
hi DiffAdd                 gui=underline   guifg=bg      guibg=#2263cc


" html {{{1
hi htmlLink                gui=underline   guifg=#a866aa guibg=bg   
hi htmlBold                gui=underline   guifg=bg      guibg=#668aaa     
hi htmlBoldUnderline       gui=underline   guifg=#668aaa guibg=bg   
hi htmlItalic              gui=underline   guifg=bg      guibg=#9544cc
hi htmlUnderlineItalic     gui=underline   guifg=#9544cc guibg=bg   
hi htmlBoldItalic          gui=underline   guifg=bg      guibg=#334caa
hi htmlBoldUnderlineItalic gui=underline   guifg=#334caa guibg=bg   
hi htmlUnderline           gui=underline   guifg=fg      guibg=bg   

"}}}1
" vim:set nowrap foldmethod=marker expandtab:
