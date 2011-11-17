" vim: set tw=0 sw=4 sts=4 et:

" Vim color file
" Maintainer: Datila Carvalho <datila@saci.homeip.net>
" Last Change: November, 3, 2003
" Version: 0.1

" This is a VIM's version of the emacs color theme
" _Billw_ created by Bill White.

set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name = "billw"


""" Colors

" GUI colors
hi Cursor               guifg=fg guibg=cornsilk
hi CursorIM             guifg=NONE guibg=cornsilk
"hi Directory
"hi DiffAdd
"hi DiffChange
"hi DiffDelete
"hi DiffText
hi ErrorMsg             gui=bold guifg=White guibg=Red
"hi VertSplit
"hi Folded
"hi FoldColumn
"hi IncSearch
"hi LineNr
hi ModeMsg              gui=bold
"hi MoreMsg
"hi NonText
hi Normal               guibg=black guifg=cornsilk
"hi Question
hi Search               gui=bold guifg=Black guibg=cornsilk
"hi SpecialKey
hi StatusLine           guifg=orange1
hi StatusLineNC         guifg=yellow4
"hi Title
hi Visual               guifg=gray35 guibg=fg
hi VisualNOS            gui=bold guifg=black guibg=fg
hi WarningMsg           guifg=White guibg=Tomato
"hi WildMenu

" Colors for syntax highlighting
hi Comment              guifg=gold

hi Constant             guifg=mediumspringgreen
    hi String           guifg=orange
    hi Character        guifg=orange
    hi Number           guifg=mediumspringgreen
    hi Boolean          guifg=mediumspringgreen
    hi Float            guifg=mediumspringgreen

hi Identifier           guifg=yellow
    hi Function         guifg=mediumspringgreen

hi Statement            gui=bold guifg=cyan1
    hi Conditional      gui=bold guifg=cyan1
    hi Repeat           gui=bold guifg=cyan1
    hi Label            guifg=cyan1
    hi Operator         guifg=cyan1
    "hi Keyword
    "hi Exception

hi PreProc              guifg=LightSteelBlue
    hi Include          guifg=LightSteelBlue
    hi Define           guifg=LightSteelBlue
    hi Macro            guifg=LightSteelBlue
    hi PreCondit        guifg=LightSteelBlue

hi Type                 guifg=yellow
    hi StorageClass     guifg=cyan1
    hi Structure        gui=bold guifg=cyan1
    hi Typedef          guifg=cyan1

"hi Special
    ""Underline Character
    "hi SpecialChar      gui=underline
    "hi Tag              gui=bold,underline
    ""Statement
    "hi Delimiter        gui=bold
    ""Bold comment (in Java at least)
    "hi SpecialComment   gui=bold
    "hi Debug            gui=bold

hi Underlined           gui=underline

hi Ignore               guifg=bg

hi Error                gui=bold guifg=White guibg=Red

"hi Todo
