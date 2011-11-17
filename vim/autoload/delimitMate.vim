" File:        autoload/delimitMate.vim
" Version:     2.6
" Modified:    2011-01-14
" Description: This plugin provides auto-completion for quotes, parens, etc.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      Read ":help delimitMate".
" ============================================================================

" Utilities {{{

let delimitMate_loaded = 1

function! delimitMate#ShouldJump() "{{{
	" Returns 1 if the next character is a closing delimiter.
	let col = col('.')
	let lcol = col('$')
	let char = getline('.')[col - 1]

	" Closing delimiter on the right.
	for cdel in b:_l_delimitMate_right_delims + b:_l_delimitMate_quotes_list
		if char == cdel
			return 1
		endif
	endfor

	" Closing delimiter with space expansion.
	let nchar = getline('.')[col]
	if b:_l_delimitMate_expand_space && char == " "
		for cdel in b:_l_delimitMate_right_delims + b:_l_delimitMate_quotes_list
			if nchar == cdel
				return 1
			endif
		endfor
	endif

	" Closing delimiter with CR expansion.
	let uchar = getline(line('.') + 1)[0]
	if b:_l_delimitMate_expand_cr && char == ""
		for cdel in b:_l_delimitMate_right_delims + b:_l_delimitMate_quotes_list
			if uchar == cdel
				return 1
			endif
		endfor
	endif

	return 0
endfunction "}}}

function! delimitMate#IsEmptyPair(str) "{{{
	for pair in b:_l_delimitMate_matchpairs_list
		if a:str == join( split( pair, ':' ),'' )
			return 1
		endif
	endfor
	for quote in b:_l_delimitMate_quotes_list
		if a:str == quote . quote
			return 1
		endif
	endfor
	return 0
endfunction "}}}

function! delimitMate#IsCRExpansion() " {{{
	let nchar = getline(line('.')-1)[-1:]
	let schar = getline(line('.')+1)[:0]
	let isEmpty = getline('.') == ""
	if index(b:_l_delimitMate_left_delims, nchar) > -1 &&
				\ index(b:_l_delimitMate_left_delims, nchar) == index(b:_l_delimitMate_right_delims, schar) &&
				\ isEmpty
		return 1
	elseif index(b:_l_delimitMate_quotes_list, nchar) > -1 &&
				\ index(b:_l_delimitMate_quotes_list, nchar) == index(b:_l_delimitMate_quotes_list, schar) &&
				\ isEmpty
		return 1
	else
		return 0
	endif
endfunction " }}} delimitMate#IsCRExpansion()

function! delimitMate#IsSpaceExpansion() " {{{
	let line = getline('.')
	let col = col('.')-2
	if col > 0
		let pchar = line[col - 1]
		let nchar = line[col + 2]
		let isSpaces = (line[col] == line[col+1] && line[col] == " ")

		if index(b:_l_delimitMate_left_delims, pchar) > -1 &&
				\ index(b:_l_delimitMate_left_delims, pchar) == index(b:_l_delimitMate_right_delims, nchar) &&
				\ isSpaces
			return 1
		elseif index(b:_l_delimitMate_quotes_list, pchar) > -1 &&
				\ index(b:_l_delimitMate_quotes_list, pchar) == index(b:_l_delimitMate_quotes_list, nchar) &&
				\ isSpaces
			return 1
		endif
	endif
	return 0
endfunction " }}} IsSpaceExpansion()

function! delimitMate#WithinEmptyPair() "{{{
	let cur = strpart( getline('.'), col('.')-2, 2 )
	return delimitMate#IsEmptyPair( cur )
endfunction "}}}

function! delimitMate#WriteBefore(str) "{{{
	let len = len(a:str)
	let line = getline('.')
	let col = col('.')-2
	if col < 0
		call setline('.',line[(col+len+1):])
	else
		call setline('.',line[:(col)].line[(col+len+1):])
	endif
	return a:str
endfunction " }}}

function! delimitMate#WriteAfter(str) "{{{
	let len = len(a:str)
	let line = getline('.')
	let col = col('.')-2
	if (col) < 0
		call setline('.',a:str.line)
	else
		call setline('.',line[:(col)].a:str.line[(col+len):])
	endif
	return ''
endfunction " }}}

function! delimitMate#GetSyntaxRegion(line, col) "{{{
	return synIDattr(synIDtrans(synID(a:line, a:col, 1)), 'name')
endfunction " }}}

function! delimitMate#GetCurrentSyntaxRegion() "{{{
	let col = col('.')
	if  col == col('$')
		let col = col - 1
	endif
	return delimitMate#GetSyntaxRegion(line('.'), col)
endfunction " }}}

function! delimitMate#GetCurrentSyntaxRegionIf(char) "{{{
	let col = col('.')
	let origin_line = getline('.')
	let changed_line = strpart(origin_line, 0, col - 1) . a:char . strpart(origin_line, col - 1)
	call setline('.', changed_line)
	let region = delimitMate#GetSyntaxRegion(line('.'), col)
	call setline('.', origin_line)
	return region
endfunction "}}}

function! delimitMate#IsForbidden(char) "{{{
	if b:_l_delimitMate_excluded_regions_enabled == 0
		return 0
	endif
	"let result = index(b:_l_delimitMate_excluded_regions_list, delimitMate#GetCurrentSyntaxRegion()) >= 0
	if index(b:_l_delimitMate_excluded_regions_list, delimitMate#GetCurrentSyntaxRegion()) >= 0
		"echom "Forbidden 1!"
		return 1
	endif
	let region = delimitMate#GetCurrentSyntaxRegionIf(a:char)
	"let result = index(b:_l_delimitMate_excluded_regions_list, region) >= 0
	"return result || region == 'Comment'
	"echom "Forbidden 2!"
	return index(b:_l_delimitMate_excluded_regions_list, region) >= 0
endfunction "}}}

function! delimitMate#FlushBuffer() " {{{
	let b:_l_delimitMate_buffer = []
	return ''
endfunction " }}}

function! delimitMate#BalancedParens(char) "{{{
	" Returns:
	" = 0 => Parens balanced.
	" > 0 => More opening parens.
	" < 0 => More closing parens.

	let line = getline('.')
	let col = col('.') - 2
	let col = col >= 0 ? col : 0
	let list = split(line, '\zs')
	let left = b:_l_delimitMate_left_delims[index(b:_l_delimitMate_right_delims, a:char)]
	let right = a:char
	let opening = 0
	let closing = 0

	" If the cursor is not at the beginning, count what's behind it.
	if col > 0
		  " Find the first opening paren:
		  let start = index(list, left)
		  " Must be before cursor:
		  let start = start < col ? start : col - 1
		  " Now count from the first opening until the cursor, this will prevent
		  " extra closing parens from being counted.
		  let opening = count(list[start : col - 1], left)
		  let closing = count(list[start : col - 1], right)
		  " I don't care if there are more closing parens than opening parens.
		  let closing = closing > opening ? opening : closing
	endif

	" Evaluate parens from the cursor to the end:
	let opening += count(list[col :], left)
	let closing += count(list[col :], right)

	"echom "–––––––––"
	"echom line
	"echom col
	""echom left.":".a:char
	"echom string(list)
	"echom string(list[start : col - 1]) . " : " . string(list[col :])
	"echom opening . " - " . closing . " = " . (opening - closing)

	" Return the found balance:
	return opening - closing
endfunction "}}}

function! delimitMate#RmBuffer(num) " {{{
	if len(b:_l_delimitMate_buffer) > 0
	   call remove(b:_l_delimitMate_buffer, 0, (a:num-1))
	endif
	return ""
endfunction " }}}

" }}}

" Doers {{{
function! delimitMate#SkipDelim(char) "{{{
	if delimitMate#IsForbidden(a:char)
		return a:char
	endif
	let col = col('.') - 1
	let line = getline('.')
	if col > 0
		let cur = line[col]
		let pre = line[col-1]
	else
		let cur = line[col]
		let pre = ""
	endif
	if pre == "\\"
		" Escaped character
		return a:char
	elseif cur == a:char
		" Exit pair
		"return delimitMate#WriteBefore(a:char)
		return a:char . delimitMate#Del()
	elseif delimitMate#IsEmptyPair( pre . a:char )
		" Add closing delimiter and jump back to the middle.
		call insert(b:_l_delimitMate_buffer, a:char)
		return delimitMate#WriteAfter(a:char)
	else
		" Nothing special here, return the same character.
		return a:char
	endif
endfunction "}}}

function! delimitMate#ParenDelim(char) " {{{
	if delimitMate#IsForbidden(a:char)
		return ''
	endif
	" Try to balance matchpairs
	if b:_l_delimitMate_balance_matchpairs &&
				\ delimitMate#BalancedParens(a:char) <= 0
		return ''
	endif
	let line = getline('.')
	let col = col('.')-2
	let left = b:_l_delimitMate_left_delims[index(b:_l_delimitMate_right_delims,a:char)]
	let smart_matchpairs = substitute(b:_l_delimitMate_smart_matchpairs, '\\!', left, 'g')
	let smart_matchpairs = substitute(smart_matchpairs, '\\#', a:char, 'g')
	"echom left.':'.smart_matchpairs . ':' . matchstr(line[col+1], smart_matchpairs)
	if b:_l_delimitMate_smart_matchpairs != '' &&
				\ line[col+1:] =~ smart_matchpairs
		return ''
	elseif (col) < 0
		call setline('.',a:char.line)
		call insert(b:_l_delimitMate_buffer, a:char)
	else
		"echom string(col).':'.line[:(col)].'|'.line[(col+1):]
		call setline('.',line[:(col)].a:char.line[(col+1):])
		call insert(b:_l_delimitMate_buffer, a:char)
	endif
	return ''
endfunction " }}}

function! delimitMate#QuoteDelim(char) "{{{
	if delimitMate#IsForbidden(a:char)
		return a:char
	endif
	let line = getline('.')
	let col = col('.') - 2
	if line[col] == "\\"
		" Seems like a escaped character, insert one quotation mark.
		return a:char
	elseif line[col + 1] == a:char &&
				\ index(b:_l_delimitMate_nesting_quotes, a:char) < 0
		" Get out of the string.
		return a:char . delimitMate#Del()
	elseif (line[col] =~ '\w' && a:char == "'") ||
				\ (b:_l_delimitMate_smart_quotes &&
				\ (line[col] =~ '\w' ||
				\ line[col + 1] =~ '\w'))
		" Seems like an apostrophe or a smart quote case, insert a single quote.
		return a:char
	elseif (line[col] == a:char && line[col + 1 ] != a:char) && b:_l_delimitMate_smart_quotes
		" Seems like we have an unbalanced quote, insert one quotation mark and jump to the middle.
		call insert(b:_l_delimitMate_buffer, a:char)
		return delimitMate#WriteAfter(a:char)
	else
		" Insert a pair and jump to the middle.
		call insert(b:_l_delimitMate_buffer, a:char)
		call delimitMate#WriteAfter(a:char)
		return a:char
	endif
endfunction "}}}

function! delimitMate#JumpOut(char) "{{{
	if delimitMate#IsForbidden(a:char)
		return a:char
	endif
	let line = getline('.')
	let col = col('.')-2
	if line[col+1] == a:char
		return a:char . delimitMate#Del()
	else
		return a:char
	endif
endfunction " }}}

function! delimitMate#JumpAny(key) " {{{
	if delimitMate#IsForbidden('')
		return a:key
	endif
	if !delimitMate#ShouldJump()
		return a:key
	endif
	" Let's get the character on the right.
	let char = getline('.')[col('.')-1]
	if char == " "
		" Space expansion.
		"let char = char . getline('.')[col('.')] . delimitMate#Del()
		return char . getline('.')[col('.')] . delimitMate#Del() . delimitMate#Del()
		"call delimitMate#RmBuffer(1)
	elseif char == ""
		" CR expansion.
		"let char = "\<CR>" . getline(line('.') + 1)[0] . "\<Del>"
		let b:_l_delimitMate_buffer = []
		return "\<CR>" . getline(line('.') + 1)[0] . "\<Del>"
	else
		"call delimitMate#RmBuffer(1)
		return char . delimitMate#Del()
	endif
endfunction " delimitMate#JumpAny() }}}

function! delimitMate#JumpMany() " {{{
	let line = getline('.')[col('.') - 1 : ]
	let len = len(line)
	let rights = ""
	let found = 0
	let i = 0
	while i < len
		let char = line[i]
		if index(b:_l_delimitMate_quotes_list, char) >= 0 ||
					\ index(b:_l_delimitMate_right_delims, char) >= 0
			let rights .= "\<Right>"
			let found = 1
		elseif found == 0
			let rights .= "\<Right>"
		else
			break
		endif
		let i += 1
	endwhile
	if found == 1
		return rights
	else
		return ''
	endif
endfunction " delimitMate#JumpMany() }}}

function! delimitMate#ExpandReturn() "{{{
	if delimitMate#IsForbidden("")
		return "\<CR>"
	endif
	if delimitMate#WithinEmptyPair()
		" Expand:
		call delimitMate#FlushBuffer()
		"return "\<Esc>a\<CR>x\<CR>\<Esc>k$\"_xa"
		return "\<CR>\<UP>\<Esc>o"
	else
		return "\<CR>"
	endif
endfunction "}}}

function! delimitMate#ExpandSpace() "{{{
	if delimitMate#IsForbidden("\<Space>")
		return "\<Space>"
	endif
	if delimitMate#WithinEmptyPair()
		" Expand:
		call insert(b:_l_delimitMate_buffer, 's')
		return delimitMate#WriteAfter(' ') . "\<Space>"
	else
		return "\<Space>"
	endif
endfunction "}}}

function! delimitMate#BS() " {{{
	if delimitMate#IsForbidden("")
		return "\<BS>"
	endif
	if delimitMate#WithinEmptyPair()
		"call delimitMate#RmBuffer(1)
		return "\<BS>" . delimitMate#Del()
"        return "\<Right>\<BS>\<BS>"
	elseif delimitMate#IsSpaceExpansion()
		"call delimitMate#RmBuffer(1)
		return "\<BS>" . delimitMate#Del()
	elseif delimitMate#IsCRExpansion()
		return "\<BS>\<Del>"
	else
		return "\<BS>"
	endif
endfunction " }}} delimitMate#BS()

function! delimitMate#Del() " {{{
	if len(b:_l_delimitMate_buffer) > 0
		let line = getline('.')
		let col = col('.') - 2
		call delimitMate#RmBuffer(1)
		call setline('.', line[:col] . line[col+2:])
		return ''
	else
		return "\<Del>"
	endif
endfunction " }}}

function! delimitMate#Finish(move_back) " {{{
	let len = len(b:_l_delimitMate_buffer)
	if len > 0
		let buffer = join(b:_l_delimitMate_buffer, '')
		let len2 = len(buffer)
		" Reset buffer:
		let b:_l_delimitMate_buffer = []
		let line = getline('.')
		let col = col('.') -2
		"echom 'col: ' . col . '-' . line[:col] . "|" . line[col+len+1:] . '%' . buffer
		if col < 0
			call setline('.', line[col+len2+1:])
		else
			call setline('.', line[:col] . line[col+len2+1:])
		endif
		let i = 1
		let lefts = ""
		while i <= len && a:move_back
			let lefts = lefts . "\<Left>"
			let i += 1
		endwhile
		return substitute(buffer, "s", "\<Space>", 'g') . lefts
	endif
	return ''
endfunction " }}}

" }}}

" Tools: {{{
function! delimitMate#TestMappings() "{{{
	let options = sort(keys(delimitMate#OptionsList()))
	let optoutput = ['delimitMate Report', '==================', '', '* Options: ( ) default, (g) global, (b) buffer','']
	for option in options
		exec 'call add(optoutput, ''('.(exists('b:delimitMate_'.option) ? 'b' : exists('g:delimitMate_'.option) ? 'g' : ' ').') delimitMate_''.option.'' = ''.string(b:_l_delimitMate_'.option.'))'
	endfor
	call append(line('$'), optoutput + ['--------------------',''])

	" Check if mappings were set. {{{
	let imaps = b:_l_delimitMate_right_delims
	let imaps = imaps + ( b:_l_delimitMate_autoclose ? b:_l_delimitMate_left_delims : [] )
	let imaps = imaps +
				\ b:_l_delimitMate_quotes_list +
				\ b:_l_delimitMate_apostrophes_list +
				\ ['<BS>', '<S-BS>', '<Del>', '<S-Tab>', '<Esc>'] +
				\ ['<Up>', '<Down>', '<Left>', '<Right>', '<LeftMouse>', '<RightMouse>'] +
				\ ['<Home>', '<End>', '<PageUp>', '<PageDown>', '<S-Down>', '<S-Up>', '<C-G>g']
	let imaps = imaps + ( b:_l_delimitMate_expand_cr ?  ['<CR>'] : [] )
	let imaps = imaps + ( b:_l_delimitMate_expand_space ?  ['<Space>'] : [] )

	let vmaps =
				\ b:_l_delimitMate_right_delims +
				\ b:_l_delimitMate_left_delims +
				\ b:_l_delimitMate_quotes_list

	let ibroken = []
	for map in imaps
		if maparg(map, "i") !~? 'delimitMate'
			let output = ''
			if map == '|'
				let map = '<Bar>'
			endif
			redir => output | execute "verbose imap ".map | redir END
			let ibroken = ibroken + [map.": is not set:"] + split(output, '\n')
		endif
	endfor

	unlet! output
	if ibroken == []
		let output = ['* Mappings:', '', 'All mappings were set-up.', '--------------------', '', '']
	else
		let output = ['* Mappings:', ''] + ibroken + ['--------------------', '']
	endif
	call append('$', output+['* Showcase:', ''])
	" }}}
	if b:_l_delimitMate_autoclose
		" {{{
		for i in range(len(b:_l_delimitMate_left_delims))
			exec "normal Go0\<C-D>Open: " . b:_l_delimitMate_left_delims[i]. "|"
			exec "normal o0\<C-D>Delete: " . b:_l_delimitMate_left_delims[i] . "\<BS>|"
			exec "normal o0\<C-D>Exit: " . b:_l_delimitMate_left_delims[i] . b:_l_delimitMate_right_delims[i] . "|"
			if b:_l_delimitMate_expand_space == 1
				exec "normal o0\<C-D>Space: " . b:_l_delimitMate_left_delims[i] . " |"
				exec "normal o0\<C-D>Delete space: " . b:_l_delimitMate_left_delims[i] . " \<BS>|"
			endif
			if b:_l_delimitMate_expand_cr == 1
				exec "normal o0\<C-D>Car return: " . b:_l_delimitMate_left_delims[i] . "\<CR>|"
				exec "normal Go0\<C-D>Delete car return: " . b:_l_delimitMate_left_delims[i] . "\<CR>0\<C-D>\<BS>|"
			endif
			call append(line('$'), '')
		endfor
		for i in range(len(b:_l_delimitMate_quotes_list))
			exec "normal Go0\<C-D>Open: " . b:_l_delimitMate_quotes_list[i]	. "|"
			exec "normal o0\<C-D>Delete: " . b:_l_delimitMate_quotes_list[i] . "\<BS>|"
			exec "normal o0\<C-D>Exit: " . b:_l_delimitMate_quotes_list[i] . b:_l_delimitMate_quotes_list[i] . "|"
			if b:_l_delimitMate_expand_space == 1
				exec "normal o0\<C-D>Space: " . b:_l_delimitMate_quotes_list[i] . " |"
				exec "normal o0\<C-D>Delete space: " . b:_l_delimitMate_quotes_list[i] . " \<BS>|"
			endif
			if b:_l_delimitMate_expand_cr == 1
				exec "normal o0\<C-D>Car return: " . b:_l_delimitMate_quotes_list[i] . "\<CR>|"
				exec "normal Go0\<C-D>Delete car return: " . b:_l_delimitMate_quotes_list[i] . "\<CR>\<BS>|"
			endif
			call append(line('$'), '')
		endfor
		"}}}
	else
		"{{{
		for i in range(len(b:_l_delimitMate_left_delims))
			exec "normal GoOpen & close: " . b:_l_delimitMate_left_delims[i]	. b:_l_delimitMate_right_delims[i] . "|"
			exec "normal oDelete: " . b:_l_delimitMate_left_delims[i] . b:_l_delimitMate_right_delims[i] . "\<BS>|"
			exec "normal oExit: " . b:_l_delimitMate_left_delims[i] . b:_l_delimitMate_right_delims[i] . b:_l_delimitMate_right_delims[i] . "|"
			if b:_l_delimitMate_expand_space == 1
				exec "normal oSpace: " . b:_l_delimitMate_left_delims[i] . b:_l_delimitMate_right_delims[i] . " |"
				exec "normal oDelete space: " . b:_l_delimitMate_left_delims[i] . b:_l_delimitMate_right_delims[i] . " \<BS>|"
			endif
			if b:_l_delimitMate_expand_cr == 1
				exec "normal oCar return: " . b:_l_delimitMate_left_delims[i] . b:_l_delimitMate_right_delims[i] . "\<CR>|"
				exec "normal GoDelete car return: " . b:_l_delimitMate_left_delims[i] . b:_l_delimitMate_right_delims[i] . "\<CR>\<BS>|"
			endif
			call append(line('$'), '')
		endfor
		for i in range(len(b:_l_delimitMate_quotes_list))
			exec "normal GoOpen & close: " . b:_l_delimitMate_quotes_list[i]	. b:_l_delimitMate_quotes_list[i] . "|"
			exec "normal oDelete: " . b:_l_delimitMate_quotes_list[i] . b:_l_delimitMate_quotes_list[i] . "\<BS>|"
			exec "normal oExit: " . b:_l_delimitMate_quotes_list[i] . b:_l_delimitMate_quotes_list[i] . b:_l_delimitMate_quotes_list[i] . "|"
			if b:_l_delimitMate_expand_space == 1
				exec "normal oSpace: " . b:_l_delimitMate_quotes_list[i] . b:_l_delimitMate_quotes_list[i] . " |"
				exec "normal oDelete space: " . b:_l_delimitMate_quotes_list[i] . b:_l_delimitMate_quotes_list[i] . " \<BS>|"
			endif
			if b:_l_delimitMate_expand_cr == 1
				exec "normal oCar return: " . b:_l_delimitMate_quotes_list[i] . b:_l_delimitMate_quotes_list[i] . "\<CR>|"
				exec "normal GoDelete car return: " . b:_l_delimitMate_quotes_list[i] . b:_l_delimitMate_quotes_list[i] . "\<CR>\<BS>|"
			endif
			call append(line('$'), '')
		endfor
	endif "}}}
	redir => setoptions | set | filetype | redir END
	call append(line('$'), split(setoptions,"\n")
				\ + ['--------------------'])
	setlocal nowrap
endfunction "}}}

function! delimitMate#OptionsList() "{{{
	return {'autoclose' : 1,'matchpairs': &matchpairs, 'quotes' : '" '' `', 'nesting_quotes' : [], 'expand_cr' : 0, 'expand_space' : 0, 'smart_quotes' : 1, 'smart_matchpairs' : '\w', 'balance_matchpairs' : 0, 'excluded_regions' : 'Comment', 'excluded_ft' : '', 'apostrophes' : ''}
endfunction " delimitMate#OptionsList }}}
"}}}

" vim:foldmethod=marker:foldcolumn=4
