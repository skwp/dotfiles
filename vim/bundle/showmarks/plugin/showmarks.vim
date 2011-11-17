" Display marks in the signs column
" Maintainer:	A. Politz <cbyvgmn@su-gevre.qr>
" Last change: 2008-02-06
" v0.1
"
"ShowMarks
"
"Give a visual aid to navigate marks, by displaying them as signs
"(obviously needs the +signs feature).
"
"commands
"--------
"
":DoShowMarks
"  show marks for current buffer
":DoShowMarks!
"  show marks for all buffers
":NoShowMarks
"  disable it for current buffer
":NoShowMarks!
"  disable it for all buffers
"
":[count]ShowMarksOnce 
"  Display marks for [count] Cursorhold 
"  events. Mostly for mapping it like :
"  nnoremap ` :ShowMarksOnce<cr>`
"
":[count]PreviewMarks
"  Display marks of current buffer in pvw.
"  Like ':marks', but at the top of the window ;-).
"  [count] is the same sa above.
"
"variables
"--------
"
"let g:showmarks_marks = "abcdef...."
"  the marks you want to have displayed.
"hlShowMarks
"  the highlight color

"I suggest to lower the value of 'updatetime'.

if exists('loaded_showmarks')
  finish
endif

let s:cpo=&cpo
set cpo&vim

let loaded_showmarks = 1

if version < 700
  com DoShowMarks echohl Error | echo "Sorry, you need vim7 for this plugin (Showmarks)." | echohl None | delc DoShowMarks
  finish
endif

if !has('signs')
  com DoShowMarks 
	\echohl Error 
	\| echo "Sorry, your version does not support signs (Showmarks). You may still use the PreviewMarks command." 
	\| echohl None | delc DoShowMarks
else
  com  -bar -bang DoShowMarks 
        \if <bang>0 | call showmarks#ShowMarks('global,enable') | else | call showmarks#ShowMarks('enable,local') | endif
  com  -bar -bang NoShowMarks 
        \if <bang>0 | call showmarks#ShowMarks('global') | else | call showmarks#ShowMarks('') | endif
  com   -bar -bang -count=1 ShowMarksOnce call showmarks#ShowMarks('once',<count>,<bang>0)
endif

com!  -bar -bang -count=0 PreviewMarks call showmarks#ShowMarks('preview',<count>)

let &cpo=s:cpo
unlet s:cpo
