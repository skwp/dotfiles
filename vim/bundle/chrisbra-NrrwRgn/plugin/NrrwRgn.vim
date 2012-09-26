" NrrwRgn.vim - Narrow Region plugin for Vim
" -------------------------------------------------------------
" Version:	   0.29
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: Mon, 20 Aug 2012 19:34:23 +0200
"
" Script: http://www.vim.org/scripts/script.php?script_id=3075
" Copyright:   (c) 2009, 2010 by Christian Brabandt
"			   The VIM LICENSE applies to histwin.vim
"			   (see |copyright|) except use "NrrwRgn.vim"
"			   instead of "Vim".
"			   No warranty, express or implied.
"	 *** ***   Use At-Your-Own-Risk!   *** ***
" GetLatestVimScripts: 3075 29 :AutoInstall: NrrwRgn.vim
"
" Init: {{{1
let s:cpo= &cpo
if exists("g:loaded_nrrw_rgn") || &cp
  finish
endif
set cpo&vim
let g:loaded_nrrw_rgn = 1

" Debug Setting
let s:debug=0
if s:debug
	exe "call nrrwrgn#Debug(1)"
endif

" ----------------------------------------------------------------------------
" Public Interface: {{{1

" Define the Command aliases "{{{2
com! -range -bang NRPrepare :<line1>,<line2>NRP<bang>
com! -range NarrowRegion :<line1>,<line2>NR
com! -bang NRMulti :NRM<bang>
com! -bang NarrowWindow :NW
com! -bang NRLast :NRL

" Define the actual Commands "{{{2
com! -range -bang NR	 :<line1>, <line2>call nrrwrgn#NrrwRgn(<q-bang>)
com! -range NRP  :exe ":" . <line1> . ',' . <line2> . 'call nrrwrgn#Prepare()'
com! NRV :call nrrwrgn#VisualNrrwRgn(visualmode())
com! NUD :call nrrwrgn#UnifiedDiff()
com! -bang NW	 :exe ":" . line('w0') . ',' . line('w$') . "call nrrwrgn#NrrwRgn(<q-bang>)"
com! -bang NRM :call nrrwrgn#NrrwRgnDoPrepare(<q-bang>)
com! -bang NRL :call nrrwrgn#LastNrrwRgn(<q-bang>)

" Define the Mapping: "{{{2
if !hasmapto('<Plug>NrrwrgnDo')
	xmap <unique> <Leader>nr <Plug>NrrwrgnDo
endif
if !hasmapto('<Plug>NrrwrgnBangDo')
	xmap <unique> <Leader>Nr <Plug>NrrwrgnBangDo
endif
if !hasmapto('VisualNrrwRgn')
	xnoremap <unique> <script> <Plug>NrrwrgnDo <sid>VisualNrrwRgn
endif
if !hasmapto('VisualNrrwRgnBang')
	xnoremap <unique> <script> <Plug>NrrwrgnBangDo <sid>VisualNrrwBang
endif
xnoremap <sid>VisualNrrwRgn :<c-u>call nrrwrgn#VisualNrrwRgn(visualmode(),'')<cr>
xnoremap <sid>VisualNrrwBang :<c-u>call nrrwrgn#VisualNrrwRgn(visualmode(),'!')<cr>

" Restore: "{{{1
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\"
