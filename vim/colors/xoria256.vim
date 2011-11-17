" Vim color file
" Name:     xoria256.vim
" Version:  0.3.2
" License:  Public Domain
" Maintainer:   Dmitriy Y. Zotikov (xio) <xio@ungrund.org>
"
" Heavily based on 'moria' color scheme.
"
" Sould work in a 256 color terminal (like latest versions of xterm, konsole,
" etc).  Will not, however, work in 88 color terminals like urxvt.
"
" Color numbers (0-255) see:
" http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
"
" TODO:
"   - Diff (currently *VERY* ugly)
"   - Html



if &t_Co != 256 && ! has("gui_running")
  echomsg ""
  echomsg "err: please use GUI or a 256-color terminal (so that t_Co=256 could be set)"
  echomsg ""
  finish
endif

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

" Which one is right?
"let colors_name = "xoria256"
let g:colors_name = "xoria256"



hi Normal   cterm=none  ctermfg=252 ctermbg=234 gui=none    guifg=#d0d0d0   guibg=#202020

hi Cursor   cterm=none  ctermfg=bg  ctermbg=214 gui=none    guifg=bg    guibg=#ffaf00
hi CursorColumn cterm=none          ctermbg=238 gui=none            guibg=#444444
hi CursorLine   cterm=none          ctermbg=238 gui=none            guibg=#444444
hi lCursor  cterm=none  ctermfg=0   ctermbg=40  gui=none    guifg=#000000   guibg=#00df00
"hi CursorIM    cterm=      ctermfg=    ctermbg=    gui=        guifg=      guibg=
hi IncSearch    cterm=none  ctermfg=0   ctermbg=223 gui=none    guifg=#000000   guibg=#ffdfaf
hi Search   cterm=none  ctermfg=0   ctermbg=149 gui=none    guifg=#000000   guibg=#afdf5f
hi ErrorMsg cterm=none  ctermfg=15  ctermbg=160 gui=bold    guifg=#ffffff   guibg=#df0000
hi WarningMsg   cterm=bold  ctermfg=196 ctermbg=bg  gui=bold    guifg=#ff0000   guibg=bg
hi ModeMsg  cterm=bold  ctermfg=fg  ctermbg=bg  gui=bold    guifg=fg    guibg=bg
hi MoreMsg  cterm=bold  ctermfg=250 ctermbg=bg  gui=bold    guifg=#bcbcbc   guibg=bg
hi Question cterm=bold  ctermfg=113 ctermbg=bg  gui=bold    guifg=#87df7f   guibg=bg

hi StatusLine   cterm=bold  ctermfg=fg  ctermbg=239 gui=bold    guifg=fg    guibg=#4e4e4e
hi StatusLineNC cterm=none  ctermfg=fg  ctermbg=237 gui=none    guifg=fg    guibg=#3a3a3a
hi User1    cterm=none  ctermfg=15  ctermbg=20  gui=none    guifg=#ffffff   guibg=#0000df
hi User2    cterm=none  ctermfg=46  ctermbg=20  gui=none    guifg=#00ff00   guibg=#0000df
hi User3    cterm=none  ctermfg=46  ctermbg=20  gui=none    guifg=#00ff00   guibg=#0000df
hi User4    cterm=none  ctermfg=50  ctermbg=20  gui=none    guifg=#00ffdf   guibg=#0000df
hi User5    cterm=none  ctermfg=46  ctermbg=20  gui=none    guifg=#00ff00   guibg=#0000df
hi VertSplit    cterm=reverse   ctermfg=fg  ctermbg=237 gui=reverse guifg=fg    guibg=#3a3a3a

hi WildMenu cterm=bold  ctermfg=0   ctermbg=184 gui=bold    guifg=#000000   guibg=#dfdf00
"hi Menu    cterm=      ctermfg=    ctermbg=    gui=        guifg=      guibg=
"hi Scrollbar   cterm=      ctermfg=    ctermbg=    gui=        guifg=      guibg=
"hi Tooltip cterm=      ctermfg=    ctermbg=    gui=        guifg=      guibg=

"hi MBENormal   cterm=      ctermfg=    ctermbg=    gui=        guifg=      guibg=
"hi MBEChanged  cterm=      ctermfg=    ctermbg=    gui=        guifg=      guibg=
"hi MBEVisibleNormal cterm= ctermfg=    ctermbg=    gui=        guifg=      guibg=
"hi MBEVisibleChanged cterm=    ctermfg=    ctermbg=    gui=        guifg=      guibg=

"hi DiffText    cterm=bold  ctermfg=fg  ctermbg=20  gui=bold    guifg=fg    guibg=#0000df
"hi DiffDelete  cterm=none  ctermfg=fg  ctermbg=88  gui=none    guifg=fg    guibg=#870000
"hi DiffChange  cterm=none  ctermfg=fg  ctermbg=18  gui=none    guifg=fg    guibg=#000087
"hi DiffAdd cterm=none  ctermfg=fg  ctermbg=28  gui=none    guifg=fg    guibg=#008700

hi Folded   cterm=none  ctermfg=255 ctermbg=60  gui=none    guifg=#eeeeee   guibg=#5f5f87
"hi Folded  cterm=none  ctermfg=251 ctermbg=240 gui=bold    guifg=#c6c6c6   guibg=#585858
"hi Folded  cterm=none  ctermfg=251 ctermbg=95  gui=none    guifg=#c6c6c6   guibg=#585858
hi FoldColumn   cterm=none  ctermfg=248 ctermbg=58  gui=none    guifg=#a8a8a8   guibg=bg
hi SignColumn   cterm=none  ctermfg=248 ctermbg=bg  gui=none    guifg=#a8a8a8   guibg=bg

hi Directory    cterm=none  ctermfg=39  ctermbg=bg  gui=none    guifg=#00afff   guibg=bg
hi LineNr   cterm=none  ctermfg=248         gui=none    guifg=#a8a8a8
hi NonText  cterm=bold  ctermfg=248 ctermbg=bg  gui=bold    guifg=#a8a8a8   guibg=bg
hi SpecialKey   cterm=none  ctermfg=77  ctermbg=bg  gui=none    guifg=#5fdf5f   guibg=bg
hi Title    cterm=none  ctermfg=0   ctermbg=184 gui=none    guifg=#000000   guibg=#dfdf00
hi Visual   cterm=none  ctermfg=24  ctermbg=153 gui=none    guifg=#005f87   guibg=#afdfff
"hi Visual  cterm=none  ctermfg=18  ctermbg=153 gui=none    guifg=#005f87   guibg=#afdfff
hi VisualNOS    cterm=bold,underline ctermfg=247 ctermbg=bg gui=bold,underline guifg=#9e9e9e guibg=bg

hi Comment  cterm=none  ctermfg=244 ctermbg=bg  gui=none    guifg=#808080   guibg=bg
""" COLD
hi Constant cterm=none  ctermfg=187 ctermbg=bg  gui=none    guifg=#dfdfaf   guibg=bg
""" COLD-DARK
"hi Constant    cterm=none  ctermfg=223 ctermbg=bg  gui=none    guifg=#ffdfaf   guibg=bg
""" NEUTRAL
"hi Constant    cterm=none  ctermfg=229 ctermbg=bg  gui=none    guifg=#ffffaf   guibg=bg
""" WARM
"hi Constant    cterm=none  ctermfg=222 ctermbg=bg  gui=none    guifg=#ffdf87   guibg=bg
"hi String  cterm=      ctermfg=    ctermbg=    gui=        guifg=      guibg=
hi Error    cterm=none  ctermfg=196 ctermbg=bg  gui=none    guifg=#ff0000   guibg=bg
""" COLD
"hi Identifier  cterm=none  ctermfg=115 ctermbg=bg  gui=none    guifg=#87dfaf   guibg=bg
""" NEUTRAL
"hi Identifier  cterm=none  ctermfg=114 ctermbg=bg  gui=none    guifg=#87df87   guibg=bg
""" WARM
hi Identifier   cterm=none  ctermfg=150 ctermbg=bg  gui=none    guifg=#afdf87   guibg=bg
hi Ignore   cterm=none  ctermfg=238 ctermbg=bg  gui=none    guifg=#444444   guibg=bg
hi Number   cterm=none  ctermfg=180 ctermbg=bg  gui=none    guifg=#dfaf87   guibg=bg
"hi Number  cterm=none  ctermfg=222 ctermbg=bg  gui=none    guifg=#ffaf87   guibg=bg
"hi Number  cterm=none  ctermfg=215 ctermbg=bg  gui=none    guifg=#ffaf87   guibg=bg
"hi Number  cterm=none  ctermfg=209 ctermbg=0   gui=none    guifg=#ff875f   guibg=#000000
"hi Number  cterm=none  ctermfg=210 ctermbg=0   gui=none    guifg=#ff8787   guibg=#000000
hi PreProc  cterm=none  ctermfg=182 ctermbg=bg  gui=none    guifg=#dfafdf   guibg=bg
"hi PreProc cterm=none  ctermfg=218 ctermbg=bg  gui=none    guifg=#ffafdf   guibg=bg
""" LIGHT
"hi Special cterm=none  ctermfg=174 ctermbg=bg  gui=none    guifg=#ffafaf   guibg=bg
""" DARK
hi Special  cterm=none  ctermfg=174 ctermbg=bg  gui=none    guifg=#df8787   guibg=bg
"hi Special cterm=none  ctermfg=114 ctermbg=bg  gui=none    guifg=#87df87   guibg=bg
"hi SpecialChar cterm=      ctermfg=    ctermbg=    gui=        guifg=      guibg=
hi Statement    cterm=none  ctermfg=74  ctermbg=bg  gui=none    guifg=#5fafdf   guibg=bg
"hi Statement   cterm=none  ctermfg=75  ctermbg=bg  gui=none    guifg=#5fafff   guibg=bg
hi Todo     cterm=none  ctermfg=0   ctermbg=184 gui=none    guifg=#000000   guibg=#dfdf00
"hi Type        cterm=none  ctermfg=153 ctermbg=bg  gui=none    guifg=#afdfff   guibg=bg
hi Type     cterm=none  ctermfg=146 ctermbg=bg  gui=none    guifg=#afafdf   guibg=bg
hi Underlined   cterm=underline ctermfg=39  ctermbg=bg  gui=underline   guifg=#00afff   guibg=bg

"hi htmlBold    cterm=      ctermbg=0   ctermfg=15  guibg=bg    guifg=fg    gui=bold
"hi htmlBoldItalic cterm=   ctermbg=0   ctermfg=15  guibg=bg    guifg=fg    gui=bold,italic
"hi htmlBoldUnderline cterm=    ctermbg=0   ctermfg=15  guibg=bg    guifg=fg    gui=bold,underline
"hi htmlBoldUnderlineItalic cterm= ctermbg=0    ctermfg=15  guibg=bg    guifg=fg    gui=bold,underline,italic
"hi htmlItalic  cterm=      ctermbg=0   ctermfg=15  guibg=bg    guifg=fg    gui=italic
"hi htmlUnderline cterm=    ctermbg=0   ctermfg=15  guibg=bg    guifg=fg    gui=underline
"hi htmlUnderlineItalici cterm= ctermbg=0   ctermfg=15  guibg=bg    guifg=fg    gui=underline,italic


" For taglist plugin
if exists('loaded_taglist')
  hi TagListTagName  cterm=none ctermfg=16  ctermbg=28  gui=none    guifg=#000000   guibg=#008700
  hi TagListTagScope cterm=none ctermfg=16  ctermbg=28  gui=none    guifg=#000000   guibg=#008700
  hi TagListTitle    cterm=none ctermfg=199 ctermbg=16  gui=none    guifg=#ff00af   guibg=#000000
  hi TagListComment  cterm=none ctermfg=16  ctermbg=28  gui=none    guifg=#000000   guibg=#008700
  hi TagListFileName cterm=none ctermfg=15  ctermbg=90  gui=none    guifg=#ffffff   guibg=#870087
endif


" For features in vim v.7.0 and higher
if v:version >= 700
  hi Pmenu      cterm=none  ctermfg=0   ctermbg=246 gui=none    guifg=#000000   guibg=#949494
  hi PmenuSel   cterm=none  ctermfg=0   ctermbg=243 gui=none    guifg=#000000   guibg=#767676
  hi PmenuSbar  cterm=none  ctermfg=fg  ctermbg=243 gui=none    guifg=fg    guibg=#767676
  hi PmenuThumb cterm=none  ctermfg=bg  ctermbg=252 gui=none    guifg=bg    guibg=#d0d0d0
  
  "  if has("spell")
  "     hi SpellBad guisp=#ee2c2c   gui=undercurl
  "     hi SpellCap guisp=#2c2cee   gui=undercurl
  "     hi SpellLocal   guisp=#2ceeee   gui=undercurl
  "     hi SpellRare    guisp=#ee2cee   gui=undercurl
  "  endif
  
  hi MatchParen cterm=none  ctermfg=188 ctermbg=68  gui=bold    guifg=#dfdfdf   guibg=#5f87df
  "hi MatchParen    cterm=none  ctermfg=24  ctermbg=153 gui=none    guifg=#005f87   guibg=#afdfff
  "hi MatchParen    cterm=none  ctermfg=117 ctermbg=31  gui=bold    guifg=#87dfff   guibg=#0087af
  "hi MatchParen    cterm=none  ctermfg=187 ctermbg=67  gui=none    guifg=#005f87   guibg=#afdfff

  hi TabLineSel cterm=bold  ctermfg=fg  ctermbg=bg  gui=bold    guifg=fg    guibg=bg
  hi TabLine    cterm=underline ctermfg=fg  ctermbg=242 gui=underline   guifg=fg    guibg=#666666
  hi TabLineFill cterm=underline ctermfg=fg ctermbg=242 gui=underline   guifg=fg    guibg=#666666
endif
