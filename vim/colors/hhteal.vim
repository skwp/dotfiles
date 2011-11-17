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
hi LineNr                  gui=underline   guifg=#647564 guibg=#101c10
hi Folded                  gui=none        guifg=#647564 guibg=bg
hi FoldColumn              gui=none        guifg=#647564 guibg=bg
" title
hi Title                   gui=underline   guifg=fg      guibg=#445544 
" message
hi MoreMsg                 gui=underline   guifg=bg      guibg=#439832
hi Question                gui=underline   guifg=bg      guibg=#439832

hi NonText                 gui=underline   guifg=#202c20 guibg=#202c20
hi VertSplit               gui=underline   guifg=bg      guibg=#101c10
hi StatusLine              gui=underline   guifg=fg      guibg=#101c10
hi StatusLineNC            gui=underline   guifg=#2c3c2c guibg=#101c10

" cursor {{{1
hi WildMenu                gui=underline   guifg=bg      guibg=#99cc99
hi Cursor                  gui=underline   guifg=bg      guibg=#99cc99
hi IncSearch               gui=underline   guifg=bg      guibg=#99cc99
hi CursorIM                gui=underline   guifg=fg      guibg=#008866
hi Search                  gui=underline   guifg=bg      guibg=#339933
hi Visual                  gui=underline   guifg=bg      guibg=#668866


" message {{{1
hi ErrorMsg                gui=underline   guifg=bg      guibg=#ccdd66
hi WarningMsg              gui=underline   guifg=bg      guibg=#99cc66
hi ModeMsg                 gui=underline   guifg=bg      guibg=#339966   


"TODO
" inner {{{1
hi Normal                  gui=none        guifg=#88bb88 guibg=#223322
hi Ignore                  gui=none        guifg=bg      guibg=bg   
hi Todo                    gui=underline   guifg=bg      guibg=#99cc66
hi Error                   gui=underline   guifg=fg      guibg=#993333
hi Special                 gui=none        guifg=#66bb88 guibg=bg   
hi SpecialKey              gui=none        guifg=#66cccc guibg=bg   
hi Identifier              gui=none        guifg=#69be69 guibg=bg   
hi Constant                gui=none        guifg=#228844 guibg=bg   
hi Statement               gui=none        guifg=#99aa66 guibg=bg   
hi Comment                 gui=none        guifg=#008866 guibg=bg   
hi Underlined              gui=underline   guifg=#666699 guibg=bg   
hi Directory               gui=none        guifg=#447744 guibg=bg   
hi PreProc                 gui=none        guifg=#557755 guibg=bg   
hi Type                    gui=none        guifg=#22bb66 guibg=bg   


" diff {{{1
hi DiffText                gui=underline   guifg=bg      guibg=#99ff99
hi DiffChange              gui=underline   guifg=bg      guibg=#55aa55
hi DiffDelete              gui=none        guifg=bg      guibg=#22aa66
hi DiffAdd                 gui=underline   guifg=bg      guibg=#88cc22


" html {{{1
hi htmlLink                gui=underline   guifg=#66aa99 guibg=bg   
hi htmlBold                gui=underline   guifg=bg      guibg=#99aa66     
hi htmlBoldUnderline       gui=underline   guifg=#99aa66 guibg=bg   
hi htmlItalic              gui=underline   guifg=bg      guibg=#44cc77
hi htmlUnderlineItalic     gui=underline   guifg=#44cc77 guibg=bg   
hi htmlBoldItalic          gui=underline   guifg=bg      guibg=#66aa33
hi htmlBoldUnderlineItalic gui=underline   guifg=#66aa33 guibg=bg   
hi htmlUnderline           gui=underline   guifg=fg      guibg=bg   

"}}}1
" vim:set nowrap foldmethod=marker expandtab:
