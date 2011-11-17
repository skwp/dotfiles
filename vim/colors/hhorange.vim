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
hi LineNr                  gui=underline   guifg=#756664 guibg=#1c1200
hi Folded                  gui=none        guifg=#756664 guibg=bg
hi FoldColumn              gui=none        guifg=#756664 guibg=bg
" title
hi Title                   gui=underline   guifg=fg      guibg=#553614 
" message
hi MoreMsg                 gui=underline   guifg=bg      guibg=#983235
hi Question                gui=underline   guifg=bg      guibg=#983235

hi NonText                 gui=underline   guifg=#2c2210 guibg=#2c2210
hi VertSplit               gui=underline   guifg=bg      guibg=#1c1200
hi StatusLine              gui=underline   guifg=fg      guibg=#1c1200
hi StatusLineNC            gui=underline   guifg=#3c2e2c guibg=#1c1200

" cursor {{{1
hi WildMenu                gui=underline   guifg=bg      guibg=#cc9069
hi Cursor                  gui=underline   guifg=bg      guibg=#cc9069
hi IncSearch               gui=underline   guifg=bg      guibg=#cc9069
hi CursorIM                gui=underline   guifg=fg      guibg=#887900
hi Search                  gui=underline   guifg=bg      guibg=#994113
hi Visual                  gui=underline   guifg=bg      guibg=#886b46


" message {{{1
hi ErrorMsg                gui=underline   guifg=bg      guibg=#dd66bb
hi WarningMsg              gui=underline   guifg=bg      guibg=#cc668b
hi ModeMsg                 gui=underline   guifg=bg      guibg=#997433   


" inner {{{1
hi Normal                  gui=none        guifg=#9b8f78 guibg=#332412
hi Ignore                  gui=none        guifg=bg      guibg=bg   
hi Todo                    gui=underline   guifg=bg      guibg=#cc668b
hi Error                   gui=underline   guifg=fg      guibg=#413399
hi Special                 gui=none        guifg=#bb9466 guibg=bg   
hi SpecialKey              gui=none        guifg=#becc66 guibg=bg   
hi Identifier              gui=none        guifg=#be7569 guibg=bg   
hi Constant                gui=none        guifg=#885222 guibg=bg   
hi Statement               gui=none        guifg=#aa668f guibg=bg   
hi Comment                 gui=none        guifg=#887900 guibg=bg   
hi Underlined              gui=underline   guifg=#66996d guibg=bg   
hi Directory               gui=none        guifg=#774b44 guibg=bg   
hi PreProc                 gui=none        guifg=#775a55 guibg=bg   
hi Type                    gui=none        guifg=#bb7b22 guibg=bg   


" diff {{{1
hi DiffText                gui=underline   guifg=bg      guibg=#ffa799
hi DiffChange              gui=underline   guifg=bg      guibg=#aa6155
hi DiffDelete              gui=none        guifg=bg      guibg=#aa7922
hi DiffAdd                 gui=underline   guifg=bg      guibg=#cc2270


" html {{{1
hi htmlLink                gui=underline   guifg=#aaa366 guibg=bg   
hi htmlBold                gui=underline   guifg=bg      guibg=#aa668f     
hi htmlBoldUnderline       gui=underline   guifg=#aa668f guibg=bg   
hi htmlItalic              gui=underline   guifg=bg      guibg=#cc8a44
hi htmlUnderlineItalic     gui=underline   guifg=#cc8a44 guibg=bg   
hi htmlBoldItalic          gui=underline   guifg=bg      guibg=#aa3355
hi htmlBoldUnderlineItalic gui=underline   guifg=#aa3355 guibg=bg   
hi htmlUnderline           gui=underline   guifg=fg      guibg=bg   

"}}}1
" vim:set nowrap foldmethod=marker expandtab:
