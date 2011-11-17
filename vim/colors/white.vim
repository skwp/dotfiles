" Vim color file
" created by mksa on 30.10.2003 10:58:20 
" cool help screens
" :he group-name
" :he highlight-groups
" :he cterm-colors



set background=light
" First remove all existing highlighting.
hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name="white"

" color terminal definitions
hi Normal           ctermfg=black       ctermbg=white       guifg=black         guibg=white
hi SpecialKey       ctermfg=darkgreen                       guifg=darkgreen
hi NonText          ctermfg=black       ctermbg=white       guifg=black         guibg=white
hi Directory        ctermfg=darkcyan                        guifg=darkcyan
hi ErrorMsg         ctermfg=lightred    ctermbg=yellow      guifg=lightred      guibg=yellow
hi IncSearch        ctermfg=white       ctermbg=black       guifg=white         guibg=black
hi Search           ctermfg=white       ctermbg=black       guifg=white         guibg=black
hi MoreMsg          ctermfg=darkgreen                       guifg=darkgreen
hi ModeMsg          ctermfg=red                             guifg=red
hi LineNr           ctermfg=yellow      ctermbg=darkgrey    guifg=yellow        guibg=darkgrey
hi Question         ctermfg=darkgreen                       guifg=darkgreen
"hi StatusLine       cterm=reverse
hi StatusLineNC     cterm=reverse                           
hi VertSplit        cterm=reverse
hi Title            ctermfg=lightred    ctermbg=yellow      guifg=red
hi Visual           cterm=reverse
hi VisualNOS        cterm=reverse
hi WarningMsg       ctermfg=darkblue                        guifg=darkblue
hi WildMenu         ctermfg=black       ctermbg=darkcyan    guifg=black         guibg=darkcyan
hi Folded           ctermfg=yellow      ctermbg=darkgrey    guifg=yellow        guibg=darkgrey
hi FoldColumn       ctermfg=yellow      ctermbg=darkgrey    guifg=yellow        guibg=darkgrey
hi DiffAdd          ctermfg=white       ctermbg=red         guifg=white         guifg=red
hi DiffChange       ctermfg=yellow      ctermbg=magenta     guifg=yellow        guifg=magenta
hi DiffDelete       ctermfg=red         ctermbg=brown       guifg=red           guibg=brown
hi DiffText         ctermbg=blue                                                guibg=blue

hi Comment          ctermfg=white       ctermbg=darkgrey    guifg=white         guibg=darkgrey
hi Constant         ctermfg=darkblue                        guifg=darkblue
hi Special          ctermfg=darkred                         guifg=darkred
hi Identifier       ctermfg=darkmagenta                     guifg=darkmagenta
hi Statement        ctermfg=blue                            guifg=blue
hi Operator         ctermfg=blue                            guifg=blue
hi PreProc          ctermfg=darkmagenta                     guifg=darkmagenta
hi Type             ctermfg=blue                            guifg=blue
hi Underlined       ctermbg=Yellow      ctermfg=blue        guifg=blue
hi Ignore           ctermfg=grey                            guifg=grey
hi Error            ctermfg=white       ctermbg=red         guifg=white         guibg=red
hi Todo             ctermfg=white       ctermbg=darkgreen   guifg=white         guibg=darkgreen
hi String           ctermfg=darkgreen                       guifg=darkgreen
hi Number           ctermfg=magenta                         guifg=magenta


"vim: sw=4
