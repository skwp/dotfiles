" AnsiEsc.vim: Uses syntax highlighting.  A vim 7.0 plugin!
" Language:		Text with ansi escape sequences
" Maintainer:	Charles E. Campbell <NdrOchipS@PcampbellAfamily.Mbiz>
" Version:		12
" Date:		Dec 13, 2010
"
" Usage: :AnsiEsc
"
"   Note: this plugin requires Vince Negri's conceal-ownsyntax patch
"         See http://groups.google.com/group/vim_dev/web/vim-patches, Patch#14
"
" GetLatestVimScripts: 302 1 :AutoInstall: AnsiEsc.vim
"redraw!|call DechoSep()|call inputsave()|call input("Press <cr> to continue")|call inputrestore()
" ---------------------------------------------------------------------
"DechoTabOn
"  Load Once: {{{1
if exists("g:loaded_AnsiEsc")
 finish
endif
let g:loaded_AnsiEsc = "v12"
if v:version < 700
 echohl WarningMsg
 echo "***warning*** this version of AnsiEsc needs vim 7.0"
 echohl Normal
 finish
endif
let s:keepcpo= &cpo
set cpo&vim

" ---------------------------------------------------------------------
" AnsiEsc#AnsiEsc: toggles ansi-escape code visualization {{{2
fun! AnsiEsc#AnsiEsc(rebuild)
"  call Dfunc("AnsiEsc#AnsiEsc(rebuild=".a:rebuild.")")
  if a:rebuild
"   call Decho("rebuilding AnsiEsc tables")
   call AnsiEsc#AnsiEsc(0)
   call AnsiEsc#AnsiEsc(0)
"   call Dret("AnsiEsc#AnsiEsc")
   return
  endif
  let bn= bufnr("%")
  if !exists("s:AnsiEsc_enabled_{bn}")
   let s:AnsiEsc_enabled_{bn}= 0
  endif
  if s:AnsiEsc_enabled_{bn}
   " disable AnsiEsc highlighting
"   call Decho("disable AnsiEsc highlighting: s:AnsiEsc_ft_".bn."<".s:AnsiEsc_ft_{bn}."> bn#".bn)
   if exists("g:colors_name")|let colorname= g:colors_name|endif
   if exists("s:conckeep_{bufnr('%')}")|let &l:conc= s:conckeep_{bufnr('%')}|unlet s:conckeep_{bufnr('%')}|endif
   if exists("s:colekeep_{bufnr('%')}")|let &l:cole= s:colekeep_{bufnr('%')}|unlet s:colekeep_{bufnr('%')}|endif
   if exists("s:cocukeep_{bufnr('%')}")|let &l:cocu= s:cocukeep_{bufnr('%')}|unlet s:cocukeep_{bufnr('%')}|endif
   hi! link ansiStop NONE
   syn clear
   hi  clear
   syn reset
   exe "set ft=".s:AnsiEsc_ft_{bn}
   if exists("colorname")|exe "colors ".colorname|endif
   let s:AnsiEsc_enabled_{bn}= 0
   if has("gui_running") && has("menu") && &go =~ 'm'
    " menu support
    exe 'silent! unmenu '.g:DrChipTopLvlMenu.'AnsiEsc'
    exe 'menu '.g:DrChipTopLvlMenu.'AnsiEsc.Start<tab>:AnsiEsc		:AnsiEsc<cr>'
   endif
   let &l:hl= s:hlkeep_{bufnr("%")}
"   call Dret("AnsiEsc#AnsiEsc")
   return
  else
   let s:AnsiEsc_ft_{bn}      = &ft
   let s:AnsiEsc_enabled_{bn} = 1
"   call Decho("enable AnsiEsc highlighting: s:AnsiEsc_ft_".bn."<".s:AnsiEsc_ft_{bn}."> bn#".bn)
   if has("gui_running") && has("menu") && &go =~ 'm'
    " menu support
    exe 'silent! unmenu '.g:DrChipTopLvlMenu.'AnsiEsc'
    exe 'menu '.g:DrChipTopLvlMenu.'AnsiEsc.Stop<tab>:AnsiEsc		:AnsiEsc<cr>'
   endif

   " -----------------
   "  Conceal Support: {{{2
   " -----------------
   if has("conceal")
    if v:version < 703
     if &l:conc != 3
      let s:conckeep_{bufnr('%')}= &cole
      setlocal conc=3
"      call Decho("l:conc=".&l:conc)
     endif
    else
     if &l:cole != 3 || &l:cocu != "nv"
      let s:colekeep_{bufnr('%')}= &l:cole
      let s:cocukeep_{bufnr('%')}= &l:cocu
      setlocal cole=3 cocu=nv
"      call Decho("l:cole=".&l:cole." l:cocu=".&l:cocu)
     endif
    endif
   endif
  endif

  syn clear

  " suppress escaped sequences that don't involve colors (which may or may not be ansi-compliant)
  if has("conceal")
   syn match ansiSuppress	conceal	'\e\[[0-9;]*[^m]'
   syn match ansiSuppress	conceal	'\e\[?\d*[^m]'
   syn match ansiSuppress	conceal	'\b'
  else
   syn match ansiSuppress		'\e\[[0-9;]*[^m]'
   syn match ansiSuppress	conceal	'\e\[?\d*[^m]'
   syn match ansiSuppress		'\b'
  endif

  " ------------------------------
  " Ansi Escape Sequence Handling: {{{2
  " ------------------------------
  syn region ansiNone		start="\e\[[01;]m"  end="\e\["me=e-2 contains=ansiConceal
  syn region ansiNone		start="\e\[m"       end="\e\["me=e-2 contains=ansiConceal

  syn region ansiBlack		start="\e\[;\=0\{0,2};\=30m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRed		start="\e\[;\=0\{0,2};\=31m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiGreen		start="\e\[;\=0\{0,2};\=32m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiYellow		start="\e\[;\=0\{0,2};\=33m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlue		start="\e\[;\=0\{0,2};\=34m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiMagenta	start="\e\[;\=0\{0,2};\=35m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiCyan		start="\e\[;\=0\{0,2};\=36m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiWhite		start="\e\[;\=0\{0,2};\=37m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiBlackBg	start="\e\[;\=0\{0,2};\=\%(1;\)\=40\%(1;\)\=m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRedBg		start="\e\[;\=0\{0,2};\=\%(1;\)\=41\%(1;\)\=m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiGreenBg	start="\e\[;\=0\{0,2};\=\%(1;\)\=42\%(1;\)\=m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiYellowBg	start="\e\[;\=0\{0,2};\=\%(1;\)\=43\%(1;\)\=m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlueBg		start="\e\[;\=0\{0,2};\=\%(1;\)\=44\%(1;\)\=m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiMagentaBg	start="\e\[;\=0\{0,2};\=\%(1;\)\=45\%(1;\)\=m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiCyanBg		start="\e\[;\=0\{0,2};\=\%(1;\)\=46\%(1;\)\=m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiWhiteBg	start="\e\[;\=0\{0,2};\=\%(1;\)\=47\%(1;\)\=m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiBoldBlack	 start="\e\[;\=0\{0,2};\=\%(1;30\|30;1\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBoldRed	 start="\e\[;\=0\{0,2};\=\%(1;31\|31;1\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBoldGreen	 start="\e\[;\=0\{0,2};\=\%(1;32\|32;1\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBoldYellow	 start="\e\[;\=0\{0,2};\=\%(1;33\|33;1\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBoldBlue	 start="\e\[;\=0\{0,2};\=\%(1;34\|34;1\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBoldMagenta	 start="\e\[;\=0\{0,2};\=\%(1;35\|35;1\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBoldCyan	 start="\e\[;\=0\{0,2};\=\%(1;36\|36;1\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBoldWhite	 start="\e\[;\=0\{0,2};\=\%(1;37\|37;1\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiStandoutBlack	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;30\|30;3\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiStandoutRed	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;31\|31;3\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiStandoutGreen	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;32\|32;3\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiStandoutYellow	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;33\|33;3\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiStandoutBlue	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;34\|34;3\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiStandoutMagenta	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;35\|35;3\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiStandoutCyan	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;36\|36;3\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiStandoutWhite	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;37\|37;3\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiItalicBlack	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;30\|30;2\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiItalicRed	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;31\|31;2\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiItalicGreen	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;32\|32;2\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiItalicYellow	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;33\|33;2\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiItalicBlue	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;34\|34;2\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiItalicMagenta	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;35\|35;2\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiItalicCyan	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;36\|36;2\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiItalicWhite	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;37\|37;2\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiUnderlineBlack	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;30\|30;4\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiUnderlineRed	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;31\|31;4\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiUnderlineGreen	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;32\|32;4\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiUnderlineYellow	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;33\|33;4\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiUnderlineBlue	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;34\|34;4\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiUnderlineMagenta	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;35\|35;4\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiUnderlineCyan	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;36\|36;4\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiUnderlineWhite	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;37\|37;4\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiBlinkBlack	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;30\|30;5\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlinkRed	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;31\|31;5\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlinkGreen	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;32\|32;5\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlinkYellow	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;33\|33;5\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlinkBlue	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;34\|34;5\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlinkMagenta	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;35\|35;5\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlinkCyan	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;36\|36;5\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlinkWhite	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;37\|37;5\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiRapidBlinkBlack	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;30\|30;6\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRapidBlinkRed	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;31\|31;6\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRapidBlinkGreen	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;32\|32;6\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRapidBlinkYellow	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;33\|33;6\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRapidBlinkBlue	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;34\|34;6\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRapidBlinkMagenta	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;35\|35;6\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRapidBlinkCyan	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;36\|36;6\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRapidBlinkWhite	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;37\|37;6\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiRVBlack	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;30\|30;7\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRVRed		 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;31\|31;7\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRVGreen	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;32\|32;7\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRVYellow	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;33\|33;7\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRVBlue		 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;34\|34;7\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRVMagenta	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;35\|35;7\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRVCyan		 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;36\|36;7\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRVWhite	 start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;37\|37;7\)m" end="\e\["me=e-2 contains=ansiConceal

  if has("conceal")
   syn match ansiStop		conceal "\e\[;\=0\{1,2}m"
   syn match ansiStop		conceal "\e\[K"
   syn match ansiStop		conceal "\e\[H"
   syn match ansiStop		conceal "\e\[2J"
  else
   syn match ansiStop		"\e\[;\=0\{0,2}m"
   syn match ansiStop		"\e\[K"
   syn match ansiStop		"\e\[H"
   syn match ansiStop		"\e\[2J"
  endif

  "syn match ansiIgnore		conceal "\e\[\([56];3[0-9]\|3[0-9];[56]\)m"
  "syn match ansiIgnore		conceal "\e\[\([0-9]\+;\)\{2,}[0-9]\+m"

  " ---------------------------------------------------------------------
  " Some Color Combinations: - can't do 'em all, the qty of highlighting groups is limited! {{{2
  " ---------------------------------------------------------------------
  syn region ansiBlackBlack	 start="\e\[0\{0,2};\=\(30;40\|40;30\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRedBlack	 start="\e\[0\{0,2};\=\(31;40\|40;31\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiGreenBlack	 start="\e\[0\{0,2};\=\(32;40\|40;32\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiYellowBlack	 start="\e\[0\{0,2};\=\(33;40\|40;33\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlueBlack	 start="\e\[0\{0,2};\=\(34;40\|40;34\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiMagentaBlack	 start="\e\[0\{0,2};\=\(35;40\|40;35\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiCyanBlack	 start="\e\[0\{0,2};\=\(36;40\|40;36\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiWhiteBlack	 start="\e\[0\{0,2};\=\(37;40\|40;37\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiBlackRed	 start="\e\[0\{0,2};\=\(30;41\|41;30\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRedRed		 start="\e\[0\{0,2};\=\(31;41\|41;31\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiGreenRed	 start="\e\[0\{0,2};\=\(32;41\|41;32\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiYellowRed	 start="\e\[0\{0,2};\=\(33;41\|41;33\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlueRed	 start="\e\[0\{0,2};\=\(34;41\|41;34\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiMagentaRed	 start="\e\[0\{0,2};\=\(35;41\|41;35\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiCyanRed	 start="\e\[0\{0,2};\=\(36;41\|41;36\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiWhiteRed	 start="\e\[0\{0,2};\=\(37;41\|41;37\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiBlackGreen	 start="\e\[0\{0,2};\=\(30;42\|42;30\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRedGreen	 start="\e\[0\{0,2};\=\(31;42\|42;31\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiGreenGreen	 start="\e\[0\{0,2};\=\(32;42\|42;32\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiYellowGreen	 start="\e\[0\{0,2};\=\(33;42\|42;33\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlueGreen	 start="\e\[0\{0,2};\=\(34;42\|42;34\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiMagentaGreen	 start="\e\[0\{0,2};\=\(35;42\|42;35\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiCyanGreen	 start="\e\[0\{0,2};\=\(36;42\|42;36\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiWhiteGreen	 start="\e\[0\{0,2};\=\(37;42\|42;37\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiBlackYellow	 start="\e\[0\{0,2};\=\(30;43\|43;30\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRedYellow	 start="\e\[0\{0,2};\=\(31;43\|43;31\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiGreenYellow	 start="\e\[0\{0,2};\=\(32;43\|43;32\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiYellowYellow	 start="\e\[0\{0,2};\=\(33;43\|43;33\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlueYellow	 start="\e\[0\{0,2};\=\(34;43\|43;34\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiMagentaYellow	 start="\e\[0\{0,2};\=\(35;43\|43;35\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiCyanYellow	 start="\e\[0\{0,2};\=\(36;43\|43;36\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiWhiteYellow	 start="\e\[0\{0,2};\=\(37;43\|43;37\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiBlackBlue	 start="\e\[0\{0,2};\=\(30;44\|44;30\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRedBlue	 start="\e\[0\{0,2};\=\(31;44\|44;31\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiGreenBlue	 start="\e\[0\{0,2};\=\(32;44\|44;32\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiYellowBlue	 start="\e\[0\{0,2};\=\(33;44\|44;33\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlueBlue	 start="\e\[0\{0,2};\=\(34;44\|44;34\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiMagentaBlue	 start="\e\[0\{0,2};\=\(35;44\|44;35\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiCyanBlue	 start="\e\[0\{0,2};\=\(36;44\|44;36\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiWhiteBlue	 start="\e\[0\{0,2};\=\(37;44\|44;37\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiBlackMagenta	 start="\e\[0\{0,2};\=\(30;45\|45;30\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRedMagenta	 start="\e\[0\{0,2};\=\(31;45\|45;31\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiGreenMagenta	 start="\e\[0\{0,2};\=\(32;45\|45;32\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiYellowMagenta	 start="\e\[0\{0,2};\=\(33;45\|45;33\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlueMagenta	 start="\e\[0\{0,2};\=\(34;45\|45;34\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiMagentaMagenta	 start="\e\[0\{0,2};\=\(35;45\|45;35\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiCyanMagenta	 start="\e\[0\{0,2};\=\(36;45\|45;36\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiWhiteMagenta	 start="\e\[0\{0,2};\=\(37;45\|45;37\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiBlackCyan	 start="\e\[0\{0,2};\=\(30;46\|46;30\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRedCyan	 start="\e\[0\{0,2};\=\(31;46\|46;31\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiGreenCyan	 start="\e\[0\{0,2};\=\(32;46\|46;32\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiYellowCyan	 start="\e\[0\{0,2};\=\(33;46\|46;33\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlueCyan	 start="\e\[0\{0,2};\=\(34;46\|46;34\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiMagentaCyan	 start="\e\[0\{0,2};\=\(35;46\|46;35\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiCyanCyan	 start="\e\[0\{0,2};\=\(36;46\|46;36\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiWhiteCyan	 start="\e\[0\{0,2};\=\(37;46\|46;37\)m" end="\e\["me=e-2 contains=ansiConceal

  syn region ansiBlackWhite	 start="\e\[0\{0,2};\=\(30;47\|47;30\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiRedWhite	 start="\e\[0\{0,2};\=\(31;47\|47;31\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiGreenWhite	 start="\e\[0\{0,2};\=\(32;47\|47;32\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiYellowWhite	 start="\e\[0\{0,2};\=\(33;47\|47;33\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiBlueWhite	 start="\e\[0\{0,2};\=\(34;47\|47;34\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiMagentaWhite	 start="\e\[0\{0,2};\=\(35;47\|47;35\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiCyanWhite	 start="\e\[0\{0,2};\=\(36;47\|47;36\)m" end="\e\["me=e-2 contains=ansiConceal
  syn region ansiWhiteWhite	 start="\e\[0\{0,2};\=\(37;47\|47;37\)m" end="\e\["me=e-2 contains=ansiConceal

  syn match ansiExtended	 "\e\[;\=\(0;\)\=[34]8;\(\d*;\)*\d*m"   contains=ansiConceal

  if has("conceal")
   syn match ansiConceal		contained conceal	"\e\[\(\d*;\)*\d*m"
  else
   syn match ansiConceal		contained		"\e\[\(\d*;\)*\d*m"
  endif

  " -------------
  " Highlighting: {{{2
  " -------------
  if !has("conceal")
   " --------------
   " ansiesc_ignore: {{{3
   " --------------
   hi def link ansiConceal	Ignore
   hi def link ansiSuppress	Ignore
   hi def link ansiIgnore	ansiStop
   hi def link ansiStop		Ignore
   hi def link ansiExtended	Ignore
  endif
  let s:hlkeep_{bufnr("%")}= &l:hl
  exe "setlocal hl=".substitute(&hl,'8:[^,]\{-},','8:Ignore,',"")

  " handle 3 or more element ansi escape sequences by building syntax and highlighting rules
  " specific to the current file
  call s:MultiElementHandler()

  hi ansiNone	cterm=NONE gui=NONE

  if &t_Co == 8 || &t_Co == 256
   " ---------------------
   " eight-color handling: {{{3
   " ---------------------
"   call Decho("set up 8-color highlighting groups")
   hi ansiBlack             ctermfg=black      guifg=black                                        cterm=none         gui=none
   hi ansiRed               ctermfg=red        guifg=red                                          cterm=none         gui=none
   hi ansiGreen             ctermfg=green      guifg=green                                        cterm=none         gui=none
   hi ansiYellow            ctermfg=yellow     guifg=yellow                                       cterm=none         gui=none
   hi ansiBlue              ctermfg=blue       guifg=blue                                         cterm=none         gui=none
   hi ansiMagenta           ctermfg=magenta    guifg=magenta                                      cterm=none         gui=none
   hi ansiCyan              ctermfg=cyan       guifg=cyan                                         cterm=none         gui=none
   hi ansiWhite             ctermfg=white      guifg=white                                        cterm=none         gui=none

   hi ansiBlackBg           ctermbg=black      guibg=black                                        cterm=none         gui=none
   hi ansiRedBg             ctermbg=red        guibg=red                                          cterm=none         gui=none
   hi ansiGreenBg           ctermbg=green      guibg=green                                        cterm=none         gui=none
   hi ansiYellowBg          ctermbg=yellow     guibg=yellow                                       cterm=none         gui=none
   hi ansiBlueBg            ctermbg=blue       guibg=blue                                         cterm=none         gui=none
   hi ansiMagentaBg         ctermbg=magenta    guibg=magenta                                      cterm=none         gui=none
   hi ansiCyanBg            ctermbg=cyan       guibg=cyan                                         cterm=none         gui=none
   hi ansiWhiteBg           ctermbg=white      guibg=white                                        cterm=none         gui=none

   hi ansiBoldBlack         ctermfg=black      guifg=black                                        cterm=bold         gui=bold
   hi ansiBoldRed           ctermfg=red        guifg=red                                          cterm=bold         gui=bold
   hi ansiBoldGreen         ctermfg=green      guifg=green                                        cterm=bold         gui=bold
   hi ansiBoldYellow        ctermfg=yellow     guifg=yellow                                       cterm=bold         gui=bold
   hi ansiBoldBlue          ctermfg=blue       guifg=blue                                         cterm=bold         gui=bold
   hi ansiBoldMagenta       ctermfg=magenta    guifg=magenta                                      cterm=bold         gui=bold
   hi ansiBoldCyan          ctermfg=cyan       guifg=cyan                                         cterm=bold         gui=bold
   hi ansiBoldWhite         ctermfg=white      guifg=white                                        cterm=bold         gui=bold

   hi ansiStandoutBlack     ctermfg=black      guifg=black                                        cterm=standout     gui=standout
   hi ansiStandoutRed       ctermfg=red        guifg=red                                          cterm=standout     gui=standout
   hi ansiStandoutGreen     ctermfg=green      guifg=green                                        cterm=standout     gui=standout
   hi ansiStandoutYellow    ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=standout
   hi ansiStandoutBlue      ctermfg=blue       guifg=blue                                         cterm=standout     gui=standout
   hi ansiStandoutMagenta   ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=standout
   hi ansiStandoutCyan      ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=standout
   hi ansiStandoutWhite     ctermfg=white      guifg=white                                        cterm=standout     gui=standout

   hi ansiItalicBlack       ctermfg=black      guifg=black                                        cterm=italic       gui=italic
   hi ansiItalicRed         ctermfg=red        guifg=red                                          cterm=italic       gui=italic
   hi ansiItalicGreen       ctermfg=green      guifg=green                                        cterm=italic       gui=italic
   hi ansiItalicYellow      ctermfg=yellow     guifg=yellow                                       cterm=italic       gui=italic
   hi ansiItalicBlue        ctermfg=blue       guifg=blue                                         cterm=italic       gui=italic
   hi ansiItalicMagenta     ctermfg=magenta    guifg=magenta                                      cterm=italic       gui=italic
   hi ansiItalicCyan        ctermfg=cyan       guifg=cyan                                         cterm=italic       gui=italic
   hi ansiItalicWhite       ctermfg=white      guifg=white                                        cterm=italic       gui=italic

   hi ansiUnderlineBlack    ctermfg=black      guifg=black                                        cterm=underline    gui=underline
   hi ansiUnderlineRed      ctermfg=red        guifg=red                                          cterm=underline    gui=underline
   hi ansiUnderlineGreen    ctermfg=green      guifg=green                                        cterm=underline    gui=underline
   hi ansiUnderlineYellow   ctermfg=yellow     guifg=yellow                                       cterm=underline    gui=underline
   hi ansiUnderlineBlue     ctermfg=blue       guifg=blue                                         cterm=underline    gui=underline
   hi ansiUnderlineMagenta  ctermfg=magenta    guifg=magenta                                      cterm=underline    gui=underline
   hi ansiUnderlineCyan     ctermfg=cyan       guifg=cyan                                         cterm=underline    gui=underline
   hi ansiUnderlineWhite    ctermfg=white      guifg=white                                        cterm=underline    gui=underline

   hi ansiBlinkBlack        ctermfg=black      guifg=black                                        cterm=standout     gui=undercurl
   hi ansiBlinkRed          ctermfg=red        guifg=red                                          cterm=standout     gui=undercurl
   hi ansiBlinkGreen        ctermfg=green      guifg=green                                        cterm=standout     gui=undercurl
   hi ansiBlinkYellow       ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=undercurl
   hi ansiBlinkBlue         ctermfg=blue       guifg=blue                                         cterm=standout     gui=undercurl
   hi ansiBlinkMagenta      ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=undercurl
   hi ansiBlinkCyan         ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=undercurl
   hi ansiBlinkWhite        ctermfg=white      guifg=white                                        cterm=standout     gui=undercurl

   hi ansiRapidBlinkBlack   ctermfg=black      guifg=black                                        cterm=standout     gui=undercurl
   hi ansiRapidBlinkRed     ctermfg=red        guifg=red                                          cterm=standout     gui=undercurl
   hi ansiRapidBlinkGreen   ctermfg=green      guifg=green                                        cterm=standout     gui=undercurl
   hi ansiRapidBlinkYellow  ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=undercurl
   hi ansiRapidBlinkBlue    ctermfg=blue       guifg=blue                                         cterm=standout     gui=undercurl
   hi ansiRapidBlinkMagenta ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=undercurl
   hi ansiRapidBlinkCyan    ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=undercurl
   hi ansiRapidBlinkWhite   ctermfg=white      guifg=white                                        cterm=standout     gui=undercurl

   hi ansiRVBlack           ctermfg=black      guifg=black                                        cterm=reverse      gui=reverse
   hi ansiRVRed             ctermfg=red        guifg=red                                          cterm=reverse      gui=reverse
   hi ansiRVGreen           ctermfg=green      guifg=green                                        cterm=reverse      gui=reverse
   hi ansiRVYellow          ctermfg=yellow     guifg=yellow                                       cterm=reverse      gui=reverse
   hi ansiRVBlue            ctermfg=blue       guifg=blue                                         cterm=reverse      gui=reverse
   hi ansiRVMagenta         ctermfg=magenta    guifg=magenta                                      cterm=reverse      gui=reverse
   hi ansiRVCyan            ctermfg=cyan       guifg=cyan                                         cterm=reverse      gui=reverse
   hi ansiRVWhite           ctermfg=white      guifg=white                                        cterm=reverse      gui=reverse

   hi ansiBlackBlack        ctermfg=black      ctermbg=black      guifg=Black      guibg=Black    cterm=none         gui=none
   hi ansiRedBlack          ctermfg=red        ctermbg=black      guifg=Red        guibg=Black    cterm=none         gui=none
   hi ansiGreenBlack        ctermfg=green      ctermbg=black      guifg=Green      guibg=Black    cterm=none         gui=none
   hi ansiYellowBlack       ctermfg=yellow     ctermbg=black      guifg=Yellow     guibg=Black    cterm=none         gui=none
   hi ansiBlueBlack         ctermfg=blue       ctermbg=black      guifg=Blue       guibg=Black    cterm=none         gui=none
   hi ansiMagentaBlack      ctermfg=magenta    ctermbg=black      guifg=Magenta    guibg=Black    cterm=none         gui=none
   hi ansiCyanBlack         ctermfg=cyan       ctermbg=black      guifg=Cyan       guibg=Black    cterm=none         gui=none
   hi ansiWhiteBlack        ctermfg=white      ctermbg=black      guifg=White      guibg=Black    cterm=none         gui=none

   hi ansiBlackRed          ctermfg=black      ctermbg=red        guifg=Black      guibg=Red      cterm=none         gui=none
   hi ansiRedRed            ctermfg=red        ctermbg=red        guifg=Red        guibg=Red      cterm=none         gui=none
   hi ansiGreenRed          ctermfg=green      ctermbg=red        guifg=Green      guibg=Red      cterm=none         gui=none
   hi ansiYellowRed         ctermfg=yellow     ctermbg=red        guifg=Yellow     guibg=Red      cterm=none         gui=none
   hi ansiBlueRed           ctermfg=blue       ctermbg=red        guifg=Blue       guibg=Red      cterm=none         gui=none
   hi ansiMagentaRed        ctermfg=magenta    ctermbg=red        guifg=Magenta    guibg=Red      cterm=none         gui=none
   hi ansiCyanRed           ctermfg=cyan       ctermbg=red        guifg=Cyan       guibg=Red      cterm=none         gui=none
   hi ansiWhiteRed          ctermfg=white      ctermbg=red        guifg=White      guibg=Red      cterm=none         gui=none

   hi ansiBlackGreen        ctermfg=black      ctermbg=green      guifg=Black      guibg=Green    cterm=none         gui=none
   hi ansiRedGreen          ctermfg=red        ctermbg=green      guifg=Red        guibg=Green    cterm=none         gui=none
   hi ansiGreenGreen        ctermfg=green      ctermbg=green      guifg=Green      guibg=Green    cterm=none         gui=none
   hi ansiYellowGreen       ctermfg=yellow     ctermbg=green      guifg=Yellow     guibg=Green    cterm=none         gui=none
   hi ansiBlueGreen         ctermfg=blue       ctermbg=green      guifg=Blue       guibg=Green    cterm=none         gui=none
   hi ansiMagentaGreen      ctermfg=magenta    ctermbg=green      guifg=Magenta    guibg=Green    cterm=none         gui=none
   hi ansiCyanGreen         ctermfg=cyan       ctermbg=green      guifg=Cyan       guibg=Green    cterm=none         gui=none
   hi ansiWhiteGreen        ctermfg=white      ctermbg=green      guifg=White      guibg=Green    cterm=none         gui=none

   hi ansiBlackYellow       ctermfg=black      ctermbg=yellow     guifg=Black      guibg=Yellow   cterm=none         gui=none
   hi ansiRedYellow         ctermfg=red        ctermbg=yellow     guifg=Red        guibg=Yellow   cterm=none         gui=none
   hi ansiGreenYellow       ctermfg=green      ctermbg=yellow     guifg=Green      guibg=Yellow   cterm=none         gui=none
   hi ansiYellowYellow      ctermfg=yellow     ctermbg=yellow     guifg=Yellow     guibg=Yellow   cterm=none         gui=none
   hi ansiBlueYellow        ctermfg=blue       ctermbg=yellow     guifg=Blue       guibg=Yellow   cterm=none         gui=none
   hi ansiMagentaYellow     ctermfg=magenta    ctermbg=yellow     guifg=Magenta    guibg=Yellow   cterm=none         gui=none
   hi ansiCyanYellow        ctermfg=cyan       ctermbg=yellow     guifg=Cyan       guibg=Yellow   cterm=none         gui=none
   hi ansiWhiteYellow       ctermfg=white      ctermbg=yellow     guifg=White      guibg=Yellow   cterm=none         gui=none

   hi ansiBlackBlue         ctermfg=black      ctermbg=blue       guifg=Black      guibg=Blue     cterm=none         gui=none
   hi ansiRedBlue           ctermfg=red        ctermbg=blue       guifg=Red        guibg=Blue     cterm=none         gui=none
   hi ansiGreenBlue         ctermfg=green      ctermbg=blue       guifg=Green      guibg=Blue     cterm=none         gui=none
   hi ansiYellowBlue        ctermfg=yellow     ctermbg=blue       guifg=Yellow     guibg=Blue     cterm=none         gui=none
   hi ansiBlueBlue          ctermfg=blue       ctermbg=blue       guifg=Blue       guibg=Blue     cterm=none         gui=none
   hi ansiMagentaBlue       ctermfg=magenta    ctermbg=blue       guifg=Magenta    guibg=Blue     cterm=none         gui=none
   hi ansiCyanBlue          ctermfg=cyan       ctermbg=blue       guifg=Cyan       guibg=Blue     cterm=none         gui=none
   hi ansiWhiteBlue         ctermfg=white      ctermbg=blue       guifg=White      guibg=Blue     cterm=none         gui=none

   hi ansiBlackMagenta      ctermfg=black      ctermbg=magenta    guifg=Black      guibg=Magenta  cterm=none         gui=none
   hi ansiRedMagenta        ctermfg=red        ctermbg=magenta    guifg=Red        guibg=Magenta  cterm=none         gui=none
   hi ansiGreenMagenta      ctermfg=green      ctermbg=magenta    guifg=Green      guibg=Magenta  cterm=none         gui=none
   hi ansiYellowMagenta     ctermfg=yellow     ctermbg=magenta    guifg=Yellow     guibg=Magenta  cterm=none         gui=none
   hi ansiBlueMagenta       ctermfg=blue       ctermbg=magenta    guifg=Blue       guibg=Magenta  cterm=none         gui=none
   hi ansiMagentaMagenta    ctermfg=magenta    ctermbg=magenta    guifg=Magenta    guibg=Magenta  cterm=none         gui=none
   hi ansiCyanMagenta       ctermfg=cyan       ctermbg=magenta    guifg=Cyan       guibg=Magenta  cterm=none         gui=none
   hi ansiWhiteMagenta      ctermfg=white      ctermbg=magenta    guifg=White      guibg=Magenta  cterm=none         gui=none

   hi ansiBlackCyan         ctermfg=black      ctermbg=cyan       guifg=Black      guibg=Cyan     cterm=none         gui=none
   hi ansiRedCyan           ctermfg=red        ctermbg=cyan       guifg=Red        guibg=Cyan     cterm=none         gui=none
   hi ansiGreenCyan         ctermfg=green      ctermbg=cyan       guifg=Green      guibg=Cyan     cterm=none         gui=none
   hi ansiYellowCyan        ctermfg=yellow     ctermbg=cyan       guifg=Yellow     guibg=Cyan     cterm=none         gui=none
   hi ansiBlueCyan          ctermfg=blue       ctermbg=cyan       guifg=Blue       guibg=Cyan     cterm=none         gui=none
   hi ansiMagentaCyan       ctermfg=magenta    ctermbg=cyan       guifg=Magenta    guibg=Cyan     cterm=none         gui=none
   hi ansiCyanCyan          ctermfg=cyan       ctermbg=cyan       guifg=Cyan       guibg=Cyan     cterm=none         gui=none
   hi ansiWhiteCyan         ctermfg=white      ctermbg=cyan       guifg=White      guibg=Cyan     cterm=none         gui=none

   hi ansiBlackWhite        ctermfg=black      ctermbg=white      guifg=Black      guibg=White    cterm=none         gui=none
   hi ansiRedWhite          ctermfg=red        ctermbg=white      guifg=Red        guibg=White    cterm=none         gui=none
   hi ansiGreenWhite        ctermfg=green      ctermbg=white      guifg=Green      guibg=White    cterm=none         gui=none
   hi ansiYellowWhite       ctermfg=yellow     ctermbg=white      guifg=Yellow     guibg=White    cterm=none         gui=none
   hi ansiBlueWhite         ctermfg=blue       ctermbg=white      guifg=Blue       guibg=White    cterm=none         gui=none
   hi ansiMagentaWhite      ctermfg=magenta    ctermbg=white      guifg=Magenta    guibg=White    cterm=none         gui=none
   hi ansiCyanWhite         ctermfg=cyan       ctermbg=white      guifg=Cyan       guibg=White    cterm=none         gui=none
   hi ansiWhiteWhite        ctermfg=white      ctermbg=white      guifg=White      guibg=White    cterm=none         gui=none

   if v:version >= 700 && exists("&t_Co") && &t_Co == 256 && exists("g:ansiesc_256color")
    " ---------------------------
    " handle 256-color terminals: {{{3
    " ---------------------------
"    call Decho("set up 256-color highlighting groups")
    let icolor= 1
    while icolor < 256
     let jcolor= 1
     exe "hi ansiHL_".icolor."_0 ctermfg=".icolor
     exe "hi ansiHL_0_".icolor." ctermbg=".icolor
"     call Decho("exe hi ansiHL_".icolor." ctermfg=".icolor)
     while jcolor < 256
      exe "hi ansiHL_".icolor."_".jcolor." ctermfg=".icolor." ctermbg=".jcolor
"      call Decho("exe hi ansiHL_".icolor."_".jcolor." ctermfg=".icolor." ctermbg=".jcolor)
      let jcolor= jcolor + 1
     endwhile
     let icolor= icolor + 1
    endwhile
   endif

  else
   " ----------------------------------
   " not 8 or 256 color terminals (gui): {{{3
   " ----------------------------------
"   call Decho("set up gui highlighting groups")
   hi ansiBlack             ctermfg=black      guifg=black                                        cterm=none         gui=none
   hi ansiRed               ctermfg=red        guifg=red                                          cterm=none         gui=none
   hi ansiGreen             ctermfg=green      guifg=green                                        cterm=none         gui=none
   hi ansiYellow            ctermfg=yellow     guifg=yellow                                       cterm=none         gui=none
   hi ansiBlue              ctermfg=blue       guifg=blue                                         cterm=none         gui=none
   hi ansiMagenta           ctermfg=magenta    guifg=magenta                                      cterm=none         gui=none
   hi ansiCyan              ctermfg=cyan       guifg=cyan                                         cterm=none         gui=none
   hi ansiWhite             ctermfg=white      guifg=white                                        cterm=none         gui=none

   hi ansiBlackBg           ctermbg=black      guibg=black                                        cterm=none         gui=none
   hi ansiRedBg             ctermbg=red        guibg=red                                          cterm=none         gui=none
   hi ansiGreenBg           ctermbg=green      guibg=green                                        cterm=none         gui=none
   hi ansiYellowBg          ctermbg=yellow     guibg=yellow                                       cterm=none         gui=none
   hi ansiBlueBg            ctermbg=blue       guibg=blue                                         cterm=none         gui=none
   hi ansiMagentaBg         ctermbg=magenta    guibg=magenta                                      cterm=none         gui=none
   hi ansiCyanBg            ctermbg=cyan       guibg=cyan                                         cterm=none         gui=none
   hi ansiWhiteBg           ctermbg=white      guibg=white                                        cterm=none         gui=none

   hi ansiBoldBlack         ctermfg=black      guifg=black                                        cterm=bold         gui=bold
   hi ansiBoldRed           ctermfg=red        guifg=red                                          cterm=bold         gui=bold
   hi ansiBoldGreen         ctermfg=green      guifg=green                                        cterm=bold         gui=bold
   hi ansiBoldYellow        ctermfg=yellow     guifg=yellow                                       cterm=bold         gui=bold
   hi ansiBoldBlue          ctermfg=blue       guifg=blue                                         cterm=bold         gui=bold
   hi ansiBoldMagenta       ctermfg=magenta    guifg=magenta                                      cterm=bold         gui=bold
   hi ansiBoldCyan          ctermfg=cyan       guifg=cyan                                         cterm=bold         gui=bold
   hi ansiBoldWhite         ctermfg=white      guifg=white                                        cterm=bold         gui=bold

   hi ansiStandoutBlack     ctermfg=black      guifg=black                                        cterm=standout     gui=standout
   hi ansiStandoutRed       ctermfg=red        guifg=red                                          cterm=standout     gui=standout
   hi ansiStandoutGreen     ctermfg=green      guifg=green                                        cterm=standout     gui=standout
   hi ansiStandoutYellow    ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=standout
   hi ansiStandoutBlue      ctermfg=blue       guifg=blue                                         cterm=standout     gui=standout
   hi ansiStandoutMagenta   ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=standout
   hi ansiStandoutCyan      ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=standout
   hi ansiStandoutWhite     ctermfg=white      guifg=white                                        cterm=standout     gui=standout

   hi ansiItalicBlack       ctermfg=black      guifg=black                                        cterm=italic       gui=italic
   hi ansiItalicRed         ctermfg=red        guifg=red                                          cterm=italic       gui=italic
   hi ansiItalicGreen       ctermfg=green      guifg=green                                        cterm=italic       gui=italic
   hi ansiItalicYellow      ctermfg=yellow     guifg=yellow                                       cterm=italic       gui=italic
   hi ansiItalicBlue        ctermfg=blue       guifg=blue                                         cterm=italic       gui=italic
   hi ansiItalicMagenta     ctermfg=magenta    guifg=magenta                                      cterm=italic       gui=italic
   hi ansiItalicCyan        ctermfg=cyan       guifg=cyan                                         cterm=italic       gui=italic
   hi ansiItalicWhite       ctermfg=white      guifg=white                                        cterm=italic       gui=italic

   hi ansiUnderlineBlack    ctermfg=black      guifg=black                                        cterm=underline    gui=underline
   hi ansiUnderlineRed      ctermfg=red        guifg=red                                          cterm=underline    gui=underline
   hi ansiUnderlineGreen    ctermfg=green      guifg=green                                        cterm=underline    gui=underline
   hi ansiUnderlineYellow   ctermfg=yellow     guifg=yellow                                       cterm=underline    gui=underline
   hi ansiUnderlineBlue     ctermfg=blue       guifg=blue                                         cterm=underline    gui=underline
   hi ansiUnderlineMagenta  ctermfg=magenta    guifg=magenta                                      cterm=underline    gui=underline
   hi ansiUnderlineCyan     ctermfg=cyan       guifg=cyan                                         cterm=underline    gui=underline
   hi ansiUnderlineWhite    ctermfg=white      guifg=white                                        cterm=underline    gui=underline

   hi ansiBlinkBlack        ctermfg=black      guifg=black                                        cterm=standout     gui=undercurl
   hi ansiBlinkRed          ctermfg=red        guifg=red                                          cterm=standout     gui=undercurl
   hi ansiBlinkGreen        ctermfg=green      guifg=green                                        cterm=standout     gui=undercurl
   hi ansiBlinkYellow       ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=undercurl
   hi ansiBlinkBlue         ctermfg=blue       guifg=blue                                         cterm=standout     gui=undercurl
   hi ansiBlinkMagenta      ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=undercurl
   hi ansiBlinkCyan         ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=undercurl
   hi ansiBlinkWhite        ctermfg=white      guifg=white                                        cterm=standout     gui=undercurl

   hi ansiRapidBlinkBlack   ctermfg=black      guifg=black                                        cterm=standout     gui=undercurl
   hi ansiRapidBlinkRed     ctermfg=red        guifg=red                                          cterm=standout     gui=undercurl
   hi ansiRapidBlinkGreen   ctermfg=green      guifg=green                                        cterm=standout     gui=undercurl
   hi ansiRapidBlinkYellow  ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=undercurl
   hi ansiRapidBlinkBlue    ctermfg=blue       guifg=blue                                         cterm=standout     gui=undercurl
   hi ansiRapidBlinkMagenta ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=undercurl
   hi ansiRapidBlinkCyan    ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=undercurl
   hi ansiRapidBlinkWhite   ctermfg=white      guifg=white                                        cterm=standout     gui=undercurl

   hi ansiRVBlack           ctermfg=black      guifg=black                                        cterm=reverse      gui=reverse
   hi ansiRVRed             ctermfg=red        guifg=red                                          cterm=reverse      gui=reverse
   hi ansiRVGreen           ctermfg=green      guifg=green                                        cterm=reverse      gui=reverse
   hi ansiRVYellow          ctermfg=yellow     guifg=yellow                                       cterm=reverse      gui=reverse
   hi ansiRVBlue            ctermfg=blue       guifg=blue                                         cterm=reverse      gui=reverse
   hi ansiRVMagenta         ctermfg=magenta    guifg=magenta                                      cterm=reverse      gui=reverse
   hi ansiRVCyan            ctermfg=cyan       guifg=cyan                                         cterm=reverse      gui=reverse
   hi ansiRVWhite           ctermfg=white      guifg=white                                        cterm=reverse      gui=reverse

   hi ansiBlackBlack        ctermfg=black      ctermbg=black      guifg=Black      guibg=Black    cterm=none         gui=none
   hi ansiRedBlack          ctermfg=black      ctermbg=black      guifg=Black      guibg=Black    cterm=none         gui=none
   hi ansiRedBlack          ctermfg=red        ctermbg=black      guifg=Red        guibg=Black    cterm=none         gui=none
   hi ansiGreenBlack        ctermfg=green      ctermbg=black      guifg=Green      guibg=Black    cterm=none         gui=none
   hi ansiYellowBlack       ctermfg=yellow     ctermbg=black      guifg=Yellow     guibg=Black    cterm=none         gui=none
   hi ansiBlueBlack         ctermfg=blue       ctermbg=black      guifg=Blue       guibg=Black    cterm=none         gui=none
   hi ansiMagentaBlack      ctermfg=magenta    ctermbg=black      guifg=Magenta    guibg=Black    cterm=none         gui=none
   hi ansiCyanBlack         ctermfg=cyan       ctermbg=black      guifg=Cyan       guibg=Black    cterm=none         gui=none
   hi ansiWhiteBlack        ctermfg=white      ctermbg=black      guifg=White      guibg=Black    cterm=none         gui=none

   hi ansiBlackRed          ctermfg=black      ctermbg=red        guifg=Black      guibg=Red      cterm=none         gui=none
   hi ansiRedRed            ctermfg=red        ctermbg=red        guifg=Red        guibg=Red      cterm=none         gui=none
   hi ansiGreenRed          ctermfg=green      ctermbg=red        guifg=Green      guibg=Red      cterm=none         gui=none
   hi ansiYellowRed         ctermfg=yellow     ctermbg=red        guifg=Yellow     guibg=Red      cterm=none         gui=none
   hi ansiBlueRed           ctermfg=blue       ctermbg=red        guifg=Blue       guibg=Red      cterm=none         gui=none
   hi ansiMagentaRed        ctermfg=magenta    ctermbg=red        guifg=Magenta    guibg=Red      cterm=none         gui=none
   hi ansiCyanRed           ctermfg=cyan       ctermbg=red        guifg=Cyan       guibg=Red      cterm=none         gui=none
   hi ansiWhiteRed          ctermfg=white      ctermbg=red        guifg=White      guibg=Red      cterm=none         gui=none

   hi ansiBlackGreen        ctermfg=black      ctermbg=green      guifg=Black      guibg=Green    cterm=none         gui=none
   hi ansiRedGreen          ctermfg=red        ctermbg=green      guifg=Red        guibg=Green    cterm=none         gui=none
   hi ansiGreenGreen        ctermfg=green      ctermbg=green      guifg=Green      guibg=Green    cterm=none         gui=none
   hi ansiYellowGreen       ctermfg=yellow     ctermbg=green      guifg=Yellow     guibg=Green    cterm=none         gui=none
   hi ansiBlueGreen         ctermfg=blue       ctermbg=green      guifg=Blue       guibg=Green    cterm=none         gui=none
   hi ansiMagentaGreen      ctermfg=magenta    ctermbg=green      guifg=Magenta    guibg=Green    cterm=none         gui=none
   hi ansiCyanGreen         ctermfg=cyan       ctermbg=green      guifg=Cyan       guibg=Green    cterm=none         gui=none
   hi ansiWhiteGreen        ctermfg=white      ctermbg=green      guifg=White      guibg=Green    cterm=none         gui=none

   hi ansiBlackYellow       ctermfg=black      ctermbg=yellow     guifg=Black      guibg=Yellow   cterm=none         gui=none
   hi ansiRedYellow         ctermfg=red        ctermbg=yellow     guifg=Red        guibg=Yellow   cterm=none         gui=none
   hi ansiGreenYellow       ctermfg=green      ctermbg=yellow     guifg=Green      guibg=Yellow   cterm=none         gui=none
   hi ansiYellowYellow      ctermfg=yellow     ctermbg=yellow     guifg=Yellow     guibg=Yellow   cterm=none         gui=none
   hi ansiBlueYellow        ctermfg=blue       ctermbg=yellow     guifg=Blue       guibg=Yellow   cterm=none         gui=none
   hi ansiMagentaYellow     ctermfg=magenta    ctermbg=yellow     guifg=Magenta    guibg=Yellow   cterm=none         gui=none
   hi ansiCyanYellow        ctermfg=cyan       ctermbg=yellow     guifg=Cyan       guibg=Yellow   cterm=none         gui=none
   hi ansiWhiteYellow       ctermfg=white      ctermbg=yellow     guifg=White      guibg=Yellow   cterm=none         gui=none

   hi ansiBlackBlue         ctermfg=black      ctermbg=blue       guifg=Black      guibg=Blue     cterm=none         gui=none
   hi ansiRedBlue           ctermfg=red        ctermbg=blue       guifg=Red        guibg=Blue     cterm=none         gui=none
   hi ansiGreenBlue         ctermfg=green      ctermbg=blue       guifg=Green      guibg=Blue     cterm=none         gui=none
   hi ansiYellowBlue        ctermfg=yellow     ctermbg=blue       guifg=Yellow     guibg=Blue     cterm=none         gui=none
   hi ansiBlueBlue          ctermfg=blue       ctermbg=blue       guifg=Blue       guibg=Blue     cterm=none         gui=none
   hi ansiMagentaBlue       ctermfg=magenta    ctermbg=blue       guifg=Magenta    guibg=Blue     cterm=none         gui=none
   hi ansiCyanBlue          ctermfg=cyan       ctermbg=blue       guifg=Cyan       guibg=Blue     cterm=none         gui=none
   hi ansiWhiteBlue         ctermfg=white      ctermbg=blue       guifg=White      guibg=Blue     cterm=none         gui=none

   hi ansiBlackMagenta      ctermfg=black      ctermbg=magenta    guifg=Black      guibg=Magenta  cterm=none         gui=none
   hi ansiRedMagenta        ctermfg=red        ctermbg=magenta    guifg=Red        guibg=Magenta  cterm=none         gui=none
   hi ansiGreenMagenta      ctermfg=green      ctermbg=magenta    guifg=Green      guibg=Magenta  cterm=none         gui=none
   hi ansiYellowMagenta     ctermfg=yellow     ctermbg=magenta    guifg=Yellow     guibg=Magenta  cterm=none         gui=none
   hi ansiBlueMagenta       ctermfg=blue       ctermbg=magenta    guifg=Blue       guibg=Magenta  cterm=none         gui=none
   hi ansiMagentaMagenta    ctermfg=magenta    ctermbg=magenta    guifg=Magenta    guibg=Magenta  cterm=none         gui=none
   hi ansiCyanMagenta       ctermfg=cyan       ctermbg=magenta    guifg=Cyan       guibg=Magenta  cterm=none         gui=none
   hi ansiWhiteMagenta      ctermfg=white      ctermbg=magenta    guifg=White      guibg=Magenta  cterm=none         gui=none

   hi ansiBlackCyan         ctermfg=black      ctermbg=cyan       guifg=Black      guibg=Cyan     cterm=none         gui=none
   hi ansiRedCyan           ctermfg=red        ctermbg=cyan       guifg=Red        guibg=Cyan     cterm=none         gui=none
   hi ansiGreenCyan         ctermfg=green      ctermbg=cyan       guifg=Green      guibg=Cyan     cterm=none         gui=none
   hi ansiYellowCyan        ctermfg=yellow     ctermbg=cyan       guifg=Yellow     guibg=Cyan     cterm=none         gui=none
   hi ansiBlueCyan          ctermfg=blue       ctermbg=cyan       guifg=Blue       guibg=Cyan     cterm=none         gui=none
   hi ansiMagentaCyan       ctermfg=magenta    ctermbg=cyan       guifg=Magenta    guibg=Cyan     cterm=none         gui=none
   hi ansiCyanCyan          ctermfg=cyan       ctermbg=cyan       guifg=Cyan       guibg=Cyan     cterm=none         gui=none
   hi ansiWhiteCyan         ctermfg=white      ctermbg=cyan       guifg=White      guibg=Cyan     cterm=none         gui=none

   hi ansiBlackWhite        ctermfg=black      ctermbg=white      guifg=Black      guibg=White    cterm=none         gui=none
   hi ansiRedWhite          ctermfg=red        ctermbg=white      guifg=Red        guibg=White    cterm=none         gui=none
   hi ansiGreenWhite        ctermfg=green      ctermbg=white      guifg=Green      guibg=White    cterm=none         gui=none
   hi ansiYellowWhite       ctermfg=yellow     ctermbg=white      guifg=Yellow     guibg=White    cterm=none         gui=none
   hi ansiBlueWhite         ctermfg=blue       ctermbg=white      guifg=Blue       guibg=White    cterm=none         gui=none
   hi ansiMagentaWhite      ctermfg=magenta    ctermbg=white      guifg=Magenta    guibg=White    cterm=none         gui=none
   hi ansiCyanWhite         ctermfg=cyan       ctermbg=white      guifg=Cyan       guibg=White    cterm=none         gui=none
   hi ansiWhiteWhite        ctermfg=white      ctermbg=white      guifg=White      guibg=White    cterm=none         gui=none
  endif
"  call Dret("AnsiEsc#AnsiEsc")
endfun

" ---------------------------------------------------------------------
" s:MultiElementHandler: builds custom syntax highlighting for three or more element ansi escape sequences {{{2
fun! s:MultiElementHandler()
"  call Dfunc("s:MultiElementHandler()")
  let curwp= SaveWinPosn(0)
  keepj 1
  keepj norm! 0
  let mehcnt = 0
  let mehrules     = []
  while search('\e\[;\=\d\+;\d\+;\d\+\(;\d\+\)*m','cW')
   let curcol  = col(".")+1
   call search('m','cW')
   let mcol    = col(".")
   let ansiesc = strpart(getline("."),curcol,mcol - curcol)
   let aecodes = split(ansiesc,'[;m]')
"   call Decho("ansiesc<".ansiesc."> aecodes=".string(aecodes))
   let skip         = 0
   let mod          = "NONE,"
   let fg           = ""
   let bg           = ""

   " if the ansiesc is
   if index(mehrules,ansiesc) == -1
    let mehrules+= [ansiesc]

    for code in aecodes

     " handle multi-code sequences (38;5;color  and 48;5;color)
     if skip == 38 && code == 5
      " handling <esc>[38;5
      let skip= 385
"      call Decho(" 1: building code=".code." skip=".skip.": mod<".mod."> fg<".fg."> bg<".bg.">")
      continue
     elseif skip == 385
      " handling <esc>[38;5;...
      if has("gui") && has("gui_running")
       let fg= s:Ansi2Gui(code)
      else
       let fg= code
      endif
      let skip= 0
"      call Decho(" 2: building code=".code." skip=".skip.": mod<".mod."> fg<".fg."> bg<".bg.">")
      continue

     elseif skip == 48 && code == 5
      " handling <esc>[48;5
      let skip= 485
"      call Decho(" 3: building code=".code." skip=".skip.": mod<".mod."> fg<".fg."> bg<".bg.">")
      continue
     elseif skip == 485
      " handling <esc>[48;5;...
      if has("gui") && has("gui_running")
       let bg= s:Ansi2Gui(code)
      else
       let bg= code
      endif
      let skip= 0
"      call Decho(" 4: building code=".code." skip=".skip.": mod<".mod."> fg<".fg."> bg<".bg.">")
      continue

     else
      let skip= 0
     endif

     " handle single-code sequences
     if code == 1
      let mod=mod."bold,"
     elseif code == 2
      let mod=mod."italic,"
     elseif code == 3
      let mod=mod."standout,"
     elseif code == 4
      let mod=mod."underline,"
     elseif code == 5 || code == 6
      let mod=mod."undercurl,"
     elseif code == 7
      let mod=mod."reverse,"

     elseif code == 30
      let fg= "black"
     elseif code == 31
      let fg= "red"
     elseif code == 32
      let fg= "green"
     elseif code == 33
      let fg= "yellow"
     elseif code == 34
      let fg= "blue"
     elseif code == 35
      let fg= "magenta"
     elseif code == 36
      let fg= "cyan"
     elseif code == 37
      let fg= "white"

     elseif code == 40
      let bg= "black"
     elseif code == 41
      let bg= "red"
     elseif code == 42
      let bg= "green"
     elseif code == 43
      let bg= "yellow"
     elseif code == 44
      let bg= "blue"
     elseif code == 45
      let bg= "magenta"
     elseif code == 46
      let bg= "cyan"
     elseif code == 47
      let bg= "white"

     elseif code == 38
      let skip= 38

     elseif code == 48
      let skip= 48
     endif

"     call Decho(" 5: building code=".code." skip=".skip.": mod<".mod."> fg<".fg."> bg<".bg.">")
    endfor

    " fixups
    let mod= substitute(mod,',$','','')

    " build syntax-recognition rule
    let mehcnt  = mehcnt + 1
    let synrule = "syn region ansiMEH".mehcnt
    let synrule = synrule.' start="\e\['.ansiesc.'"'
    let synrule = synrule.' end="\e\["me=e-2'
    let synrule = synrule." contains=ansiConceal"
"    call Decho(" exe synrule: ".synrule)
    exe synrule

    " build highlighting rule
    let hirule= "hi ansiMEH".mehcnt
    if has("gui") && has("gui_running")
     let hirule=hirule." gui=".mod
     if fg != ""| let hirule=hirule." guifg=".fg| endif
     if bg != ""| let hirule=hirule." guibg=".bg| endif
    else
     let hirule=hirule." cterm=".mod
     if fg != ""| let hirule=hirule." ctermfg=".fg| endif
     if bg != ""| let hirule=hirule." ctermbg=".bg| endif
    endif
"    call Decho(" exe hirule: ".hirule)
    exe hirule
   endif

  endwhile

  call RestoreWinPosn(curwp)
"  call Dret("s:MultiElementHandler")
endfun

" ---------------------------------------------------------------------
" s:Ansi2Gui: converts an ansi-escape sequence (for 256-color xterms) {{{2
"           to an equivalent gui color
"           colors   0- 15:
"           colors  16-231:  6x6x6 color cube, code= 16+r*36+g*6+b  with r,g,b each in [0,5]
"           colors 232-255:  grayscale ramp,   code= 10*gray + 8    with gray in [0,23] (black,white left out)
fun! s:Ansi2Gui(code)
"  call Dfunc("s:Ansi2Gui(code=)".a:code)
  let guicolor= a:code
  if a:code < 16
   let code2rgb = [ "black", "red3", "green3", "yellow3", "blue3", "magenta3", "cyan3", "gray70", "gray40", "red", "green", "yellow", "royalblue3", "magenta", "cyan", "white"]
   let guicolor = code2rgb[a:code]
  elseif a:code >= 232
   let code     = a:code - 232
   let code     = 10*code + 8
   let guicolor = printf("#%02x%02x%02x",code,code,code)
  else
   let code     = a:code - 16
   let code2rgb = [43,85,128,170,213,255]
   let r        = code2rgb[code/36]
   let g        = code2rgb[(code%36)/6]
   let b        = code2rgb[code%6]
   let guicolor = printf("#%02x%02x%02x",r,g,b)
  endif
"  call Dret("s:Ansi2Gui ".guicolor)
  return guicolor
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: ts=12 fdm=marker
