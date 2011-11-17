" Vim color file
" Name:        WuYe
" Maintainer:  Yeii
" Last Change: 2007-12-11
" Version:     0.1.1

" Init
set background=dark
if has("gui_running")
    set cursorline
endif
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name = "wuye"

""""""""\ Highlighting groups for various occasions \""""""""
hi SpecialKey   gui=NONE guifg=#000000 guibg=#00008B    cterm=NONE ctermfg=black ctermbg=darkblue
hi NonText  gui=NONE guifg=#191970 guibg=bg     cterm=NONE ctermfg=darkblue ctermbg=black
hi Directory    gui=NONE guifg=#20B2AA guibg=bg     cterm=NONE ctermfg=darkcyan ctermbg=black
hi ErrorMsg gui=NONE guifg=#FFFF00 guibg=#B22222    cterm=NONE ctermfg=yellow ctermbg=red
hi IncSearch    gui=BOLD guifg=#FF0000 guibg=bg     cterm=BOLD ctermfg=red ctermbg=black
hi Search   gui=reverse guifg=NONE guibg=#FF0000    cterm=BOLD ctermfg=red ctermbg=white
hi MoreMsg  gui=BOLD guifg=#00FF7F guibg=bg     cterm=BOLD ctermfg=darkcyan ctermbg=black
hi ModeMsg  gui=NONE guifg=#7CFC00 guibg=#00688B    cterm=NONE ctermfg=yellow ctermbg=darkcyan
hi LineNr   gui=underline guifg=#607B8B guibg=#121212   cterm=underline ctermfg=darkgrey ctermbg=black
hi Question gui=BOLD guifg=#00FF00 guibg=bg     cterm=BOLD ctermfg=green ctermbg=black
hi StatusLine   gui=NONE guifg=#FFFFFF guibg=#203080    cterm=NONE ctermfg=white ctermbg=darkblue
hi StatusLineNC gui=NONE guifg=#CDB79E guibg=#102436    cterm=NONE ctermfg=white ctermbg=darkgray
hi VertSplit    gui=NONE guifg=#CDB79E guibg=#102436    cterm=NONE ctermfg=white ctermbg=darkgray
hi Title    gui=BOLD guifg=#1E90FF guibg=bg     cterm=BOLD ctermfg=lightblue ctermbg=black
hi Visual   gui=reverse guibg=#FFFF00 guifg=#191970 cterm=reverse ctermbg=yellow ctermfg=blue
hi WarningMsg   gui=BOLD guifg=#FFFF00 guibg=bg     cterm=NONE ctermfg=lightyellow ctermbg=black
hi WildMenu gui=BOLD guifg=#000000 guibg=#7FFF00    cterm=BOLD ctermfg=black ctermbg=darkgreen
hi Folded   gui=BOLD guifg=#E0FFFF guibg=#104E8B    cterm=BOLD ctermfg=white ctermbg=darkblue
hi FoldColumn   gui=NONE guifg=#E0FFFF guibg=#104E8B    cterm=NONE ctermfg=white ctermbg=darkblue
hi DiffAdd  gui=NONE guifg=fg guibg=#008B8B     cterm=NONE ctermfg=white ctermbg=darkcyan
hi DiffChange   gui=NONE guifg=fg guibg=#008B00     cterm=NONE ctermfg=white ctermbg=darkgreen
hi DiffDelete   gui=NONE guifg=#8B3A62 guibg=bg     cterm=NONE ctermfg=darkmagenta ctermbg=black
hi DiffText gui=BOLD guifg=#FF69B4 guibg=#00008B    cterm=BOLD ctermfg=darkmagenta ctermbg=darkblue
hi Cursor   gui=NONE guifg=#000000 guibg=#00FF00    cterm=NONE ctermfg=black ctermbg=green
hi CursorIM gui=NONE guifg=fg guibg=#FF0000     cterm=NONE ctermfg=black ctermbg=red
hi CursorLine   gui=NONE guifg=NONE guibg=#001220
hi CursorColumn gui=NONE guifg=NONE guibg=#001630

""""""\ Syntax highlighting groups \""""""
hi Normal   gui=NONE guifg=#E6E6FA guibg=black  cterm=NONE ctermfg=white ctermbg=black
hi Comment  gui=NONE guifg=#4A708B guibg=bg     cterm=NONE ctermfg=grey ctermbg=black
hi Constant gui=NONE guifg=#87CEEB guibg=bg     cterm=NONE ctermfg=darkcyan ctermbg=black
    hi String   gui=NONE guifg=#A4D3EE guibg=bg     cterm=NONE ctermfg=darkcyan ctermbg=black
    hi Character    gui=NONE guifg=#87CEEB guibg=bg     cterm=NONE ctermfg=darkcyan ctermbg=black
    hi Number   gui=NONE guifg=#6495ED guibg=bg     cterm=NONE ctermfg=darkcyan ctermbg=black
    hi Boolean  gui=BOLD guifg=#A4D3EE guibg=bg     cterm=NONE ctermfg=darkcyan ctermbg=black
    hi Float    gui=NONE guifg=#6495ED guibg=bg     cterm=NONE ctermfg=darkcyan ctermbg=black
hi Identifier   gui=NONE guifg=#00BFFF guibg=bg     cterm=NONE ctermfg=lightcyan ctermbg=black
    hi Function gui=BOLD guifg=#00CED1 guibg=bg     cterm=NONE ctermfg=lightcyan ctermbg=black
hi Statement    gui=NONE guifg=#54FF9F guibg=bg     cterm=NONE ctermfg=lightgreen ctermbg=black
    hi Conditional  gui=NONE guifg=#54FF9F guibg=bg     cterm=NONE ctermfg=lightgreen ctermbg=black
    hi Repeat   gui=NONE guifg=#00FF7F guibg=bg     cterm=NONE ctermfg=lightgreen ctermbg=black
    hi Label    gui=NONE guifg=#54FF9F guibg=bg     cterm=NONE ctermfg=lightgreen ctermbg=black
    hi Operator gui=BOLD guifg=#00FA9A guibg=bg     cterm=NONE ctermfg=lightgreen ctermbg=black
    hi Keyword  gui=NONE guifg=#7CFC00 guibg=bg     cterm=NONE ctermfg=lightgreen ctermbg=black
    hi Exception    gui=NONE guifg=#90EE90 guibg=bg     cterm=NONE ctermfg=lightgreen ctermbg=black
hi PreProc  gui=NONE guifg=#8470FF guibg=bg     cterm=NONE ctermfg=magenta ctermbg=black
    hi include  gui=none guifg=#8A2BE2 guibg=bg     cterm=NONE ctermfg=lightmagenta ctermbg=black
    hi Define   gui=NONE guifg=#8470FF guibg=bg     cterm=NONE ctermfg=lightmagenta ctermbg=black
    hi Macro    gui=NONE guifg=#8470FF guibg=bg     cterm=NONE ctermfg=lightmagenta ctermbg=black
    hi PreCondit    gui=BOLD guifg=#6A5ACD guibg=bg     cterm=NONE ctermfg=lightmagenta ctermbg=black
hi Type     gui=NONE guifg=#1874CD guibg=bg     cterm=NONE ctermfg=blue ctermbg=black
    hi StorageClass gui=NONE guifg=#4169E1 guibg=bg cterm=NONE ctermfg=blue ctermbg=black
    hi Structure    gui=NONE guifg=#4169E1 guibg=bg cterm=NONE ctermfg=blue ctermbg=black
    hi Typedef  gui=BOLD guifg=#1874CD guibg=bg cterm=NONE ctermfg=blue ctermbg=black
hi Special  gui=NONE guifg=#E0B880 guibg=bg     cterm=NONE ctermfg=yellow ctermbg=black
    hi Specialchar  gui=NONE guifg=#CD6839 guibg=bg     cterm=NONE ctermfg=yellow ctermbg=black
    hi Tag      gui=NONE guifg=#CD853F guibg=bg     cterm=NONE ctermfg=yellow ctermbg=black
    hi Delimiter    gui=NONE guifg=#EE9A49 guibg=bg     cterm=NONE ctermfg=yellow ctermbg=black
    hi Debug    gui=NONE guifg=#DAA520 guibg=bg     cterm=NONE ctermfg=yellow ctermbg=black
hi Underlined   gui=underline guifg=#F0E68C guibg=bg    cterm=underline ctermfg=white ctermbg=black
hi Ignore   gui=NONE guifg=#BFBFBF guibg=bg     cterm=NONE ctermfg=grey ctermbg=black
hi Error    gui=NONE guifg=#F0E68C guibg=#FF00FF    cterm=NONE ctermfg=lightyellow ctermbg=lightmagenta
hi Todo     gui=NONE guifg=#00EEEE guibg=#551A8B    cterm=BOLD ctermfg=lightcyan ctermbg=darkgray

