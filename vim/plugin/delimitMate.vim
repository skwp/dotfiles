" File:        plugin/delimitMate.vim
" Version:     2.6
" Modified:    2011-01-14
" Description: This plugin provides auto-completion for quotes, parens, etc.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      Read ":help delimitMate".
" ============================================================================

" Initialization: {{{

if exists("g:loaded_delimitMate") || &cp
	" User doesn't want this plugin or compatible is set, let's get out!
	finish
endif
let g:loaded_delimitMate = 1

if exists("s:loaded_delimitMate") && !exists("g:delimitMate_testing")
	" Don't define the functions if they already exist: just do the work
	" (unless we are testing):
	call s:DelimitMateDo()
	finish
endif

if v:version < 700
	echoerr "delimitMate: this plugin requires vim >= 7!"
	finish
endif

let s:loaded_delimitMate = 1
let delimitMate_version = "2.6"

function! s:option_init(name, default) "{{{
	let b = exists("b:delimitMate_" . a:name)
	let g = exists("g:delimitMate_" . a:name)
	let prefix = "_l_delimitMate_"

	if !b && !g
		let sufix = a:default
	elseif !b && g
		exec "let sufix = g:delimitMate_" . a:name
	else
		exec "let sufix = b:delimitMate_" . a:name
	endif
	if exists("b:" . prefix . a:name)
		exec "unlockvar! b:" . prefix . a:name
	endif
	exec "let b:" . prefix . a:name . " = " . string(sufix)
	exec "lockvar! b:" . prefix . a:name
endfunction "}}}

function! s:init() "{{{
" Initialize variables:

	" autoclose
	call s:option_init("autoclose", 1)

	" matchpairs
	call s:option_init("matchpairs", string(&matchpairs)[1:-2])
	call s:option_init("matchpairs_list", split(b:_l_delimitMate_matchpairs, ','))
	call s:option_init("left_delims", split(b:_l_delimitMate_matchpairs, ':.,\='))
	call s:option_init("right_delims", split(b:_l_delimitMate_matchpairs, ',\=.:'))

	" quotes
	call s:option_init("quotes", "\" ' `")
	call s:option_init("quotes_list", split(b:_l_delimitMate_quotes))

	" nesting_quotes
	call s:option_init("nesting_quotes", [])

	" excluded_regions
	call s:option_init("excluded_regions", "Comment")
	call s:option_init("excluded_regions_list", split(b:_l_delimitMate_excluded_regions, ',\s*'))
	let enabled = len(b:_l_delimitMate_excluded_regions_list) > 0
	call s:option_init("excluded_regions_enabled", enabled)

	" excluded filetypes
	call s:option_init("excluded_ft", "")

	" expand_space
	if exists("b:delimitMate_expand_space") && type(b:delimitMate_expand_space) == type("")
		echom "b:delimitMate_expand_space is '".b:delimitMate_expand_space."' but it must be either 1 or 0!"
		echom "Read :help 'delimitMate_expand_space' for more details."
		unlet b:delimitMate_expand_space
		let b:delimitMate_expand_space = 1
	endif
	if exists("g:delimitMate_expand_space") && type(g:delimitMate_expand_space) == type("")
		echom "delimitMate_expand_space is '".g:delimitMate_expand_space."' but it must be either 1 or 0!"
		echom "Read :help 'delimitMate_expand_space' for more details."
		unlet g:delimitMate_expand_space
		let g:delimitMate_expand_space = 1
	endif
	call s:option_init("expand_space", 0)

	" expand_cr
	if exists("b:delimitMate_expand_cr") && type(b:delimitMate_expand_cr) == type("")
		echom "b:delimitMate_expand_cr is '".b:delimitMate_expand_cr."' but it must be either 1 or 0!"
		echom "Read :help 'delimitMate_expand_cr' for more details."
		unlet b:delimitMate_expand_cr
		let b:delimitMate_expand_cr = 1
	endif
	if exists("g:delimitMate_expand_cr") && type(g:delimitMate_expand_cr) == type("")
		echom "delimitMate_expand_cr is '".g:delimitMate_expand_cr."' but it must be either 1 or 0!"
		echom "Read :help 'delimitMate_expand_cr' for more details."
		unlet g:delimitMate_expand_cr
		let g:delimitMate_expand_cr = 1
	endif
	if ((&backspace !~ 'eol' || &backspace !~ 'start') && &backspace != 2) &&
				\ ((exists('b:delimitMate_expand_cr') && b:delimitMate_expand_cr == 1) ||
				\ (exists('g:delimitMate_expand_cr') && g:delimitMate_expand_cr == 1))
		echom "delimitMate: There seems to be some incompatibility with your settings that may interfer with the expansion of <CR>. See :help 'delimitMate_expand_cr' for details."
	endif
	call s:option_init("expand_cr", 0)

	" smart_matchpairs
	call s:option_init("smart_matchpairs", '^\%(\w\|\!\|£\|\$\|_\|["'']\s*\S\)')

	" smart_quotes
	call s:option_init("smart_quotes", 1)

	" apostrophes
	call s:option_init("apostrophes", "")
	call s:option_init("apostrophes_list", split(b:_l_delimitMate_apostrophes, ":\s*"))

	" tab2exit
	call s:option_init("tab2exit", 1)

	" balance_matchpairs
	call s:option_init("balance_matchpairs", 0)

	let b:_l_delimitMate_buffer = []

endfunction "}}} Init()

"}}}

" Functions: {{{

function! s:Map() "{{{
	" Set mappings:
	try
		let save_cpo = &cpo
		let save_keymap = &keymap
		let save_iminsert = &iminsert
		let save_imsearch = &imsearch
		set keymap=
		set cpo&vim
		if b:_l_delimitMate_autoclose
			call s:AutoClose()
		else
			call s:NoAutoClose()
		endif
		call s:ExtraMappings()
	finally
		let &cpo = save_cpo
		let &keymap = save_keymap
		let &iminsert = save_iminsert
		let &imsearch = save_imsearch
	endtry

	let b:delimitMate_enabled = 1

endfunction "}}} Map()

function! s:Unmap() " {{{
	let imaps =
				\ b:_l_delimitMate_right_delims +
				\ b:_l_delimitMate_left_delims +
				\ b:_l_delimitMate_quotes_list +
				\ b:_l_delimitMate_apostrophes_list +
				\ ['<BS>', '<S-BS>', '<Del>', '<CR>', '<Space>', '<S-Tab>', '<Esc>'] +
				\ ['<Up>', '<Down>', '<Left>', '<Right>', '<LeftMouse>', '<RightMouse>'] +
				\ ['<Home>', '<End>', '<PageUp>', '<PageDown>', '<S-Down>', '<S-Up>', '<C-G>g']

	for map in imaps
		if maparg(map, "i") =~? 'delimitMate'
			if map == '|'
				let map = '<Bar>'
			endif
			exec 'silent! iunmap <buffer> ' . map
		endif
	endfor

	if !has('gui_running')
		silent! iunmap <C-[>OC
	endif

	let b:delimitMate_enabled = 0
endfunction " }}} s:Unmap()

function! s:TestMappingsDo() "{{{
	%d
	if !exists("g:delimitMate_testing")
		silent call delimitMate#TestMappings()
	else
		let temp_varsDM = [b:_l_delimitMate_expand_space, b:_l_delimitMate_expand_cr, b:_l_delimitMate_autoclose]
		for i in [0,1]
			let b:delimitMate_expand_space = i
			let b:delimitMate_expand_cr = i
			for a in [0,1]
				let b:delimitMate_autoclose = a
				call s:init()
				call s:Unmap()
				call s:Map()
				call delimitMate#TestMappings()
				call append(line('$'),'')
			endfor
		endfor
		let b:delimitMate_expand_space = temp_varsDM[0]
		let b:delimitMate_expand_cr = temp_varsDM[1]
		let b:delimitMate_autoclose = temp_varsDM[2]
		unlet temp_varsDM
	endif
	normal gg
	g/\%^$/d
endfunction "}}}

function! s:DelimitMateDo(...) "{{{

	" First, remove all magic, if needed:
	if exists("b:delimitMate_enabled") && b:delimitMate_enabled == 1
		call s:Unmap()
	endif

	" Check if this file type is excluded:
	if exists("g:delimitMate_excluded_ft") &&
				\ index(split(g:delimitMate_excluded_ft, ','), &filetype, 0, 1) >= 0

		" Finish here:
		return 1
	endif

	" Check if user tried to disable using b:loaded_delimitMate
	if exists("b:loaded_delimitMate")
		return 1
	endif

	" Initialize settings:
	call s:init()

	" Now, add magic:
	call s:Map()

	if a:0 > 0
		echo "delimitMate has been reset."
	endif
endfunction "}}}

function! s:DelimitMateSwitch() "{{{
	if exists("b:delimitMate_enabled") && b:delimitMate_enabled
		call s:Unmap()
		echo "delimitMate has been disabled."
	else
		call s:Unmap()
		call s:init()
		call s:Map()
		echo "delimitMate has been enabled."
	endif
endfunction "}}}

function! s:Finish() " {{{
	if exists('g:delimitMate_loaded')
		return delimitMate#Finish(1)
	endif
	return ''
endfunction " }}}

function! s:FlushBuffer() " {{{
	if exists('g:delimitMate_loaded')
		return delimitMate#FlushBuffer()
	endif
	return ''
endfunction " }}}

"}}}

" Mappers: {{{
function! s:NoAutoClose() "{{{
	" inoremap <buffer> ) <C-R>=delimitMate#SkipDelim('\)')<CR>
	for delim in b:_l_delimitMate_right_delims + b:_l_delimitMate_quotes_list
		if delim == '|'
			let delim = '<Bar>'
		endif
		exec 'inoremap <silent> <Plug>delimitMate' . delim . ' <C-R>=delimitMate#SkipDelim("' . escape(delim,'"') . '")<CR>'
		exec 'silent! imap <unique> <buffer> '.delim.' <Plug>delimitMate'.delim
	endfor
endfunction "}}}

function! s:AutoClose() "{{{
	" Add matching pair and jump to the midle:
	" inoremap <silent> <buffer> ( ()<Left>
	let i = 0
	while i < len(b:_l_delimitMate_matchpairs_list)
		let ld = b:_l_delimitMate_left_delims[i] == '|' ? '<bar>' : b:_l_delimitMate_left_delims[i]
		let rd = b:_l_delimitMate_right_delims[i] == '|' ? '<bar>' : b:_l_delimitMate_right_delims[i]
		exec 'inoremap <silent> <Plug>delimitMate' . ld . ' ' . ld . '<C-R>=delimitMate#ParenDelim("' . escape(rd, '|') . '")<CR>'
		exec 'silent! imap <unique> <buffer> '.ld.' <Plug>delimitMate'.ld
		let i += 1
	endwhile

	" Exit from inside the matching pair:
	for delim in b:_l_delimitMate_right_delims
		exec 'inoremap <silent> <Plug>delimitMate' . delim . ' <C-R>=delimitMate#JumpOut("\' . delim . '")<CR>'
		exec 'silent! imap <unique> <buffer> ' . delim . ' <Plug>delimitMate'. delim
	endfor

	" Add matching quote and jump to the midle, or exit if inside a pair of matching quotes:
	" inoremap <silent> <buffer> " <C-R>=delimitMate#QuoteDelim("\"")<CR>
	for delim in b:_l_delimitMate_quotes_list
		if delim == '|'
			let delim = '<Bar>'
		endif
		exec 'inoremap <silent> <Plug>delimitMate' . delim . ' <C-R>=delimitMate#QuoteDelim("\' . delim . '")<CR>'
		exec 'silent! imap <unique> <buffer> ' . delim . ' <Plug>delimitMate' . delim
	endfor

	" Try to fix the use of apostrophes (kept for backward compatibility):
	" inoremap <silent> <buffer> n't n't
	for map in b:_l_delimitMate_apostrophes_list
		exec "inoremap <silent> " . map . " " . map
		exec 'silent! imap <unique> <buffer> ' . map . ' <Plug>delimitMate' . map
	endfor
endfunction "}}}

function! s:ExtraMappings() "{{{
	" If pair is empty, delete both delimiters:
	inoremap <silent> <Plug>delimitMateBS <C-R>=delimitMate#BS()<CR>
	if !hasmapto('<Plug>delimitMateBS','i')
		silent! imap <unique> <buffer> <BS> <Plug>delimitMateBS
	endif
	" If pair is empty, delete closing delimiter:
	inoremap <silent> <expr> <Plug>delimitMateS-BS delimitMate#WithinEmptyPair() ? "\<C-R>=delimitMate#Del()\<CR>" : "\<S-BS>"
	if !hasmapto('<Plug>delimitMateS-BS','i')
		silent! imap <unique> <buffer> <S-BS> <Plug>delimitMateS-BS
	endif
	" Expand return if inside an empty pair:
	inoremap <silent> <Plug>delimitMateCR <C-R>=delimitMate#ExpandReturn()<CR>
	if b:_l_delimitMate_expand_cr != 0 && !hasmapto('<Plug>delimitMateCR', 'i')
		silent! imap <unique> <buffer> <CR> <Plug>delimitMateCR
	endif
	" Expand space if inside an empty pair:
	inoremap <silent> <Plug>delimitMateSpace <C-R>=delimitMate#ExpandSpace()<CR>
	if b:_l_delimitMate_expand_space != 0 && !hasmapto('<Plug>delimitMateSpace', 'i')
		silent! imap <unique> <buffer> <Space> <Plug>delimitMateSpace
	endif
	" Jump over any delimiter:
	inoremap <silent> <Plug>delimitMateS-Tab <C-R>=delimitMate#JumpAny("\<S-Tab>")<CR>
	if b:_l_delimitMate_tab2exit && !hasmapto('<Plug>delimitMateS-Tab', 'i')
		silent! imap <unique> <buffer> <S-Tab> <Plug>delimitMateS-Tab
	endif
	" Change char buffer on Del:
	inoremap <silent> <Plug>delimitMateDel <C-R>=delimitMate#Del()<CR>
	if !hasmapto('<Plug>delimitMateDel', 'i')
		silent! imap <unique> <buffer> <Del> <Plug>delimitMateDel
	endif
	" Flush the char buffer on movement keystrokes or when leaving insert mode:
	for map in ['Esc', 'Left', 'Right', 'Home', 'End']
		exec 'inoremap <silent> <Plug>delimitMate'.map.' <C-R>=<SID>Finish()<CR><'.map.'>'
		if !hasmapto('<Plug>delimitMate'.map, 'i')
			exec 'silent! imap <unique> <buffer> <'.map.'> <Plug>delimitMate'.map
		endif
	endfor
	" Except when pop-up menu is active:
	for map in ['Up', 'Down', 'PageUp', 'PageDown', 'S-Down', 'S-Up']
		exec 'inoremap <silent> <expr> <Plug>delimitMate'.map.' pumvisible() ? "\<'.map.'>" : "\<C-R>=\<SID>Finish()\<CR>\<'.map.'>"'
		if !hasmapto('<Plug>delimitMate'.map, 'i')
			exec 'silent! imap <unique> <buffer> <'.map.'> <Plug>delimitMate'.map
		endif
	endfor
	" Avoid ambiguous mappings:
	for map in ['LeftMouse', 'RightMouse']
		exec 'inoremap <silent> <Plug>delimitMateM'.map.' <C-R>=delimitMate#Finish(1)<CR><'.map.'>'
		if !hasmapto('<Plug>delimitMate'.map, 'i')
			exec 'silent! imap <unique> <buffer> <'.map.'> <Plug>delimitMateM'.map
		endif
	endfor

	" Jump over next delimiters
	inoremap <buffer> <Plug>delimitMateJumpMany <C-R>=len(b:_l_delimitMate_buffer) ? delimitMate#Finish(0) : delimitMate#JumpMany()<CR>
	if !hasmapto('<Plug>delimitMateJumpMany')
		imap <silent> <buffer> <C-G>g <Plug>delimitMateJumpMany
	endif

	" The following simply creates an ambiguous mapping so vim fully processes
	" the escape sequence for terminal keys, see 'ttimeout' for a rough
	" explanation, this just forces it to work
	if !has('gui_running')
		imap <silent> <C-[>OC <RIGHT>
	endif
endfunction "}}}

"}}}

" Commands: {{{

call s:DelimitMateDo()

" Let me refresh without re-loading the buffer:
command! -bar DelimitMateReload call s:DelimitMateDo(1)

" Quick test:
command! -bar DelimitMateTest silent call s:TestMappingsDo()

" Switch On/Off:
command! -bar DelimitMateSwitch call s:DelimitMateSwitch()
"}}}

" Autocommands: {{{

augroup delimitMate
	au!
	" Run on file type change.
	"autocmd VimEnter * autocmd FileType * call <SID>DelimitMateDo()
	autocmd FileType * call <SID>DelimitMateDo()

	" Run on new buffers.
	autocmd BufNewFile,BufRead,BufEnter *
				\ if !exists('b:delimitMate_was_here') |
				\   call <SID>DelimitMateDo() |
				\   let b:delimitMate_was_here = 1 |
				\ endif

	" Flush the char buffer:
	autocmd InsertEnter * call <SID>FlushBuffer()
	autocmd BufEnter *
				\ if mode() == 'i' |
				\   call <SID>FlushBuffer() |
				\ endif

augroup END

"}}}

" GetLatestVimScripts: 2754 1 :AutoInstall: delimitMate.vim
" vim:foldmethod=marker:foldcolumn=4
