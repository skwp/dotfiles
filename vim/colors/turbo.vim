" Vim color file
" Maintainer:	Bryant Casteel
" Web Site:     http://bethings.provoplatinum.com
" Last Change:	2004 Jan. 22

" turbo -- Intended to look like the color scheme
" from Borland's Turbo C++ and Turbo Pascal.

set bg=dark
hi clear
if exists("syntax_on")
	syntax reset
endif

let colors_name = "turbo"


hi Normal		guifg=yellow	guibg=#000040				ctermfg=yellow		ctermbg=black
hi ErrorMsg		guifg=#ffffff	guibg=#287eff				ctermfg=white		ctermbg=lightblue
hi Visual		guifg=#8080ff	guibg=fg	gui=reverse		ctermfg=lightblue	ctermbg=fg		cterm=reverse
hi VisualNOS		guifg=#8080ff	guibg=fg	gui=reverse,underline	ctermfg=lightblue	ctermbg=fg		cterm=reverse,underline
hi Todo			guifg=#d14a14	guibg=#1248d1				ctermfg=red		ctermbg=darkblue
hi Search		guifg=#90fff0	guibg=#2050d0				ctermfg=white		ctermbg=darkblue	cterm=underline
hi IncSearch		guifg=#b0ffff	guibg=#2050d0				ctermfg=darkblue	ctermbg=gray


hi SpecialKey		guifg=cyan						ctermfg=darkcyan
hi Directory		guifg=cyan						ctermfg=cyan
hi Title		guifg=magenta			gui=none 		ctermfg=magenta					cterm=bold
hi WarningMsg		guifg=red						ctermfg=red
hi WildMenu		guifg=yellow	guibg=black				ctermfg=yellow		ctermbg=black		cterm=none
hi ModeMsg		guifg=#22cce2						ctermfg=lightblue
hi MoreMsg		guifg=darkgreen						ctermfg=darkgreen
hi Question		guifg=green			gui=none		ctermfg=green					cterm=none
hi NonText		guifg=#0030ff						ctermfg=darkblue

"	Split window status bar
hi StatusLine		guifg=blue	guibg=yellow	gui=none		ctermfg=blue		ctermbg=gray		cterm=none
hi StatusLineNC		guifg=black	guibg=green	gui=none		ctermfg=black		ctermbg=gray		cterm=none
hi VertSplit		guifg=black	guibg=orange	gui=none		ctermfg=black		ctermbg=gray		cterm=none

"	Folded code
hi Folded		guifg=#808080	guibg=#000040				ctermfg=darkgrey	ctermbg=black		cterm=bold
hi FoldColumn		guifg=#808080	guibg=#000040				ctermfg=darkgrey	ctermbg=black		cterm=bold
hi LineNr		guifg=#90f020						ctermfg=green					cterm=none


hi DiffAdd				guibg=darkblue							ctermbg=darkblue	cterm=none
hi DiffChange				guibg=darkmagenta						ctermbg=magenta		cterm=none
hi DiffDelete		guifg=Blue	guibg=DarkCyan	gui=bold		ctermfg=blue		ctermbg=cyan
hi DiffText		guibg=Red			gui=bold					ctermbg=red		cterm=bold

"	Cursor
hi Cursor		guifg=#000020	guibg=#ffaf38				ctermfg=bg		ctermbg=brown
hi lCursor		guifg=#ffffff	guibg=#000000				ctermfg=bg		ctermbg=darkgreen

"	Syntax highlighting:
hi Comment		guifg=darkcyan						ctermfg=darkcyan
hi Constant		guifg=darkred						ctermfg=darkred					cterm=none
hi Special		guifg=magenta			gui=none		ctermfg=magenta					cterm=none
hi Identifier		guifg=green						ctermfg=green					cterm=none
hi Statement		guifg=white			gui=bold		ctermfg=white					cterm=bold
hi PreProc		guifg=darkgreen			gui=none		ctermfg=darkgreen				cterm=none
hi type			guifg=grey			gui=bold		ctermfg=grey					cterm=bold
hi Underlined						gui=underline								cterm=underline
hi Ignore		guifg=bg						ctermfg=bg


