" theme.menu.vim:	Generates Vim themes menu and organizes themes based
" 					upon background colors
" Maintainer:		Erik Falor <rAjsBnFCybe@tzNnvy.Zpbz g?? - NOSPAM>
" Date:				Aug 30, 2007
" Version:			0.4
"

" Initialization: {{{
if exists("g:loaded_theme_menu") || &cp
	finish
endif
let g:loaded_theme_menu= "0.4"
let s:keepcpo      = &cpo
set cpo&vim
"}}}

" Script Variables: {{{
let s:menuFile = strpart(&rtp, 0, stridx(&rtp, ',')) . '/plugin/ColorSchemes.vim'
let s:menuName = '&ColorSchemes'
let s:xdigit = '[0123456789ABCDEFabcdef]'
let s:hexvals = { 0:0, 1:1, 2:2, 3:3,
			\4:4, 5:5, 6:6, 7:7,
			\8:8, 9:9, 'a':10, 'b':11,
			\'c':12, 'd':13, 'e':14, 'f':15,
			\'A':10, 'B':11, 'C':12, 'D':13,
			\'E':14, 'F':15 }
"}}}

" Library Functions {{{
function! <SID>RGBtoHSV(r, g, b) "{{{
	let h = 0
	let s = 0
	let v = 0
	if (a:b > a:g) && (a:b > a:r)
		let v = a:b
		if v != 0
			let min = 0
			if(a:r > a:g)
				let min = a:g
			else
				let min = a:r 
			endif

			let delta = v - min

			if delta != 0
				let s = (delta * 255) / v
				let h = 240 + (60 * a:r - 60 * a:g) / delta
			else 
				let s = 0
				let h = 240 + (60 * a:r - 60 * a:g)
			endif
			if h < 0 
				let h = h + 360 
			endif
		else 
			let s = 0
			let h = 0
		endif
	elseif a:g > a:r
		let v = a:g
		if v != 0
			let min = 0
			if a:r > a:b
				let min = a:b 
			else 
				let min = a:r 
			endif
			let delta = v - min
			if delta != 0
				let s = (delta * 255) / v
				let h = 120 + (60 * a:b - 60 * a:r) / delta
			else 
				let s = 0
				let h = 120 + (60 * a:b - 60 * a:r)
			endif
			if h < 0
				let h = h + 360 
			endif
		else 
			let s = 0
			let h = 0
		endif
	else
		let v = a:r
		if v != 0
			let min = 0
			if a:g > a:b
				let min = a:b
			else
				let min = a:g
			endif
			let delta = v - min
			if delta != 0
				let s = (delta * 255) / v
				let h = (60 * a:g - 60 * a:b) / delta
			else 
				let s = 0
				let h = 60 * a:g - 60 * a:b
			endif
			if h < 0
				let h = h + 360 
			endif
		else
			let s = 0
			let h = 0
		endif
	endif
	return [h, s, v]
endfunction "RGBtoHSV()
"}}}

function! <SID>IsBlack(r, g, b, h, s, v) "{{{
	if a:r == a:g && a:g == a:b && a:b == 0
		return 1
	else
		return 0
	endif
endfunction "IsBlack()}}}
	
function! <SID>IsWhite(r, g, b, h, s, v) "{{{
	if a:r == a:g && a:g == a:b && a:b == 255
		return 1
	else 
		return 0
	endif
endfunction "IsWhite()}}}

function! <SID>IsDarkGrey(r, g, b, h, s, v) "{{{
	let diffRGB = max([a:r, a:g, a:b]) - min([a:r, a:g, a:b])
	let darkGreyFuzz = 20
	if diffRGB <= darkGreyFuzz
		return 1
	else 
		return 0
	endif
endfunction "IsDarkGrey()}}}

function! <SID>IsOffWhite(r, g, b, h, s, v) "{{{
	let offWhiteSat = 32
	let offWhiteVal = 255 - 32
	if a:v >= offWhiteVal && a:s <= offWhiteSat
		return 1
	else 
		return 0
	endif
endfunction "}}}

function! <SID>IsGrey(r, g, b, h, s, v) "{{{
	let diffRGB = max([a:r, a:g, a:b]) -  min([a:r, a:g, a:b])
	let greyFuzz = 28
	let greyVal = 32

	if diffRGB > greyFuzz
		return 0
	elseif (a:s <= greyFuzz )
			\&& (a:v <= 255 - (greyVal * 1))
			\&& (a:v >= 0   + (greyVal * 1))
		return 1 
	else
		return 0
	endif
endfunction "}}}

function! <SID>IsYellow(r, g, b, h, s, v) "{{{
	if a:h > 30 && a:h <= 90
		return 1
	else 
		return 0
	endif
endfunction "}}}

function! <SID>IsGreen(r, g, b, h, s, v) "{{{
	if a:h > 90 && a:h <= 180
		return 1
	else 
		return 0
	endif
endfunction "}}}

function! <SID>IsCyan(r, g, b, h, s, v) "{{{
"	cyan will be 180 deg +/- 10 deg
	let variance = 10
	if a:h > 180 - variance && a:h < 180 + variance
		return 1
	else 
		return 0
	endif
endfunction "}}}

function! <SID>IsBlue(r, g, b, h, s, v) "{{{
	if a:h > 180 && a:h <= 270
		return 1
	else 
		return 0
	endif
endfunction "}}}

function! <SID>IsMagenta(r, g, b, h, s, v) "{{{
	if a:h > 270 && a:h <= 330
		return 1
	else 
		return 0
	endif
endfunction }}}

function! <SID>IsOrange(r, g, b, h, s, v) "{{{
	"a magic number found through trial and error
	let greenFuzz = 172 
	if a:r > a:g && a:b == 0 && a:g < greenFuzz && a:g != 0
		return 1
	else
		return 0
	endif
endfunction "}}}

function! <SID>IsRed(r, g, b, h, s, v) "{{{
	if a:h > 330 || a:h <= 30
		return 1
	else
		return 0
	endif
endfunction "}}}

function! <SID>RgbTxt2Hexes() "{{{
	"read rgb.txt, return dictionary mapping color names to hex triplet
	if exists("g:rgbtxt") && filereadable(g:rgbtxt)
		let rgbtxt = g:rgbtxt
	else
		if has("win32") || has("win64")
			let rgbtxt = expand("$VIMRUNTIME/rgb.txt")
		elseif filereadable("/usr/X11R6/lib/X11/rgb.txt")
			let rgbtxt = "/usr/X11R6/lib/X11/rgb.txt"
		elseif filereadable("/usr/share/X11/rgb.txt")
			let rgbtxt = "/usr/share/X11/rgb.txt"
		endif
	endif
	let rgbdict = {}
	if filereadable(rgbtxt)
		for line in readfile(rgbtxt)
			if line !~ '^\(!\|#\)'
				let l = matchlist(line, '\s*\(\d\+\)\s*\(\d\+\)\s*\(\d\+\)\s*\(.*\)')
				let rgbdict[tolower(l[4])] = printf('%02X%02X%02X', l[1], l[2], l[3])
			endif
		endfor
		"note: vim treats guibg=NONE as guibg=white
		let rgbdict['none'] = 'FFFFFF'
	else
		echoerr "ColorSchemeMenuMaker.vim could not open rgb.txt file at " . rgbtxt 
	endif
	return rgbdict
endfunction "}}}

function! <SID>RGBHexToHexes(rgb) "{{{
	let xdigits = '\(' . s:xdigit . '\{2\}\)'
	let pat = '\(#\)\?' . xdigits . xdigits . xdigits
	let l = matchlist(a:rgb, pat)
	if len(l) > 0
		return [ l[2], l[3], l[4] ]
	else
		return []
	endif
endfunction "}}}

function! <SID>RGBHexToInts(rgbList) "{{{
	return map(a:rgbList, '<SID>Hex2Int(v:val)')
endfunction "}}}

function! <SID>Hex2Int(hex) "{{{
	let xdigits = split(a:hex, '\zs')
	return 16 * s:hexvals[xdigits[0]] + s:hexvals[xdigits[1]]
endfunction "}}}

function! <SID>RGB2BoyColor(rgb) "{{{
	let rgbL = <SID>RGBHexToInts(<SID>RGBHexToHexes(a:rgb))
	let r = rgbL[0] | let g = rgbL[1] | let b = rgbL[2]
	let hsvL = <SID>RGBtoHSV(r, g, b)
	let h = hsvL[0] | let s = hsvL[1] | let v = hsvL[2]
	if <SID>IsBlack(r, g, b, h, s, v) == 1 | return 'black' | endif
	if <SID>IsWhite(r, g, b, h, s, v) == 1 | return 'white' | endif
	if <SID>IsGrey(r, g, b, h, s, v) == 1 | return 'grey' | endif
	if <SID>IsOffWhite(r, g, b, h, s, v) == 1 | return 'offwhite' | endif
	if <SID>IsDarkGrey(r, g, b, h, s, v) == 1 | return 'darkgrey' | endif
	if <SID>IsOrange(r, g, b, h, s, v) == 1 | return 'orange' | endif
	if <SID>IsYellow(r, g, b, h, s, v) == 1 | return 'yellow' | endif
	if <SID>IsCyan(r, g, b, h, s, v) == 1 | return 'cyan' | endif
	if <SID>IsGreen(r, g, b, h, s, v) == 1 | return 'green' | endif
	if <SID>IsBlue(r, g, b, h, s, v) == 1 | return 'blue' | endif
	if <SID>IsMagenta(r, g, b, h, s, v) == 1 | return 'magenta' | endif
	if <SID>IsRed(r, g, b, h, s, v) == 1 | return 'red' | endif
	return 'unknown'
endfunction "}}}

function! <SID>GlobThemes() "{{{
	"return list containing paths to all theme files in &runtimepath
	return split(globpath(&rtp, 'colors/*.vim'), '\n')
endfunction "}}}

function! <SID>ScanThemeBackground() "{{{
	"Read each of the theme files and find out which color
	"each theme 'basically' is.  Uses the last 'hi Normal' 
	"group found to classify by color.  Notes those color
	"files that do have more than one 'hi Normal' command.
	let name2hex = <SID>RgbTxt2Hexes()
	let themeColors = {}
	let themeNames = {}
	let i = 0
	let pat = 'hi.*\s\+Normal\s\+.\{-}guibg=\(#\?\)\(\w\+\)'
	for theme in <SID>GlobThemes()
		if filereadable(theme)

			"DEBUG
			"let i = i + 1
			"if i > 10
				"break
			"endif

			let higroupfound = 0
			let color = ''
			for line in readfile(theme)
				let bg = matchlist(line, pat)
				if len(bg) > 0
					if bg[1] == '#'
						let color = <SID>RGB2BoyColor(bg[2])
					else
						if has_key(name2hex, tolower(bg[2]))
							let color = <SID>RGB2BoyColor(name2hex[tolower(bg[2])])
						else
							let color = 'unknown'
						endif
					endif
					let higroupfound += 1
				endif
			endfor
			let themename = fnamemodify(theme, ':t:r')
			let letter = toupper(strpart(themename, 0, 1))
			if letter =~ '\d' | let letter = '#' | endif

			if len(color) < 1 
				let color = 'unknown'
			endif

			"allocate sub-dict if needed
			if !has_key(themeColors, color)
				let themeColors[color] = {}
			endif
			"allocate sub-dict if needed
			if !has_key(themeNames, letter)
				let themeNames[letter] = {}
			endif
			if higroupfound > 1
				"mark themes with many 'hi Normal' commands
				if len(color) > 0
					let themeColors[color][themename] = '*' . themename
				endif
				let themeNames[letter][themename] = '*' . themename
			else
				if len(color) > 0
					let themeColors[color][themename] = themename
				endif
				let themeNames[letter][themename] = themename
			endif
		endif
	endfor
	return [themeColors, themeNames]
endfunction "}}}

function! <SID>BuildMenu(dicts) "{{{
	"puts menu commands into a list
	let menu = []
	call add(menu, '"ColorScheme menu generated ' . strftime("%c", localtime()))
	call add(menu, '')
	call add(menu, '"Themes by color:')
	call add(menu, '')
	"count number of themes categorized by color
	let totThemes = 0
	for i in keys(a:dicts[0])
		let totThemes += len(a:dicts[0][i])
	endfor
	for color in sort(keys(a:dicts[0]))
		let numThemes = len(a:dicts[0][color])
		call add(menu, '')
		call add(menu, '"submenu '. color)
		for theme in sort(keys(a:dicts[0][color]))
			call add(menu, '9000amenu '. s:menuName. '.&Colors\ ('. totThemes . ').'
					\. color . '\ ('. numThemes . ').'
					\. a:dicts[0][color][theme]. '  :colo '. theme . '<CR>')
		endfor
	endfor
	call add(menu, '"Themes by name:')
	call add(menu, '')
	"count number of themes categorized by name
	let totThemes = 0
	for i in keys(a:dicts[1])
		let totThemes += len(a:dicts[1][i])
	endfor
	for letter in sort(keys(a:dicts[1]))
		let numThemes = len(a:dicts[1][letter])
		call add(menu, '')
		call add(menu, '"submenu '. letter)
		for theme in sort(keys(a:dicts[1][letter]))
			call add(menu, 'amenu '. s:menuName. '.&Names\ (' . totThemes . ').'
					\. letter . '\ ('. numThemes .').'
					\.  a:dicts[1][letter][theme] . '  :colo '. theme . '<CR>')
		endfor
	endfor

	call add(menu, '')
	"add a separator and a command to re-init the menu
	call add(menu, 'amenu ' . s:menuName .'.-Sep-	:')
	call add(menu, 'amenu ' . s:menuName .'.Reload\ Menu	:ReloadColors<CR>')
	call add(menu, 'amenu ' . s:menuName .'.Refresh\ Menu	:RefreshColors<CR>')
	call add(menu, '')
	call add(menu, 'command! -nargs=0		ReloadColors		call <SID>ReloadColors()')
	call add(menu, 'command! -nargs=0		RefreshColors		call <SID>RefreshColors()')
	call add(menu, '')
	call add(menu, 'if !exists("g:running_ReloadColors")')
	call add(menu, '	function! <SID>ReloadColors()')
	call add(menu, '		let g:running_ReloadColors = 1')
	call add(menu, '		aunmenu ' . s:menuName)
	call add(menu, "		execute 'source " . s:menuFile . "'")
	call add(menu, '		unlet g:running_ReloadColors')
	call add(menu, "		echomsg 'Done Reloading " . s:menuFile . "'")
	call add(menu, '	endfunction')
	call add(menu, 'endif')

	call add(menu, 'if !exists("g:running_RefreshColors")')
	call add(menu, '	function! <SID>RefreshColors()')
	call add(menu, '		let g:running_RefreshColors = 1')
	call add(menu, '		call WriteColorSchemeMenu()')
	call add(menu, '		call <SID>ReloadColors()')
	call add(menu, '		unlet g:running_RefreshColors')
	call add(menu, "		echomsg 'Done Refreshing " . s:menuFile . "'")
	call add(menu, '	endfunction')
	call add(menu, 'endif')

	return menu
endfunction "}}}

function! WriteColorSchemeMenu() "{{{
	"Builds the menu from the two dicts returned by ScanThemeBackground()
	"Stores menu in first plugin dir specified by &rtp
	let menu = <SID>BuildMenu(<SID>ScanThemeBackground())
	call writefile(menu, s:menuFile)
endfunction "}}}

function! <SID>InitMenu() "{{{
	call WriteColorSchemeMenu()
	execute "source " . s:menuFile
endfunction "}}}

"}}}

" Restore &cpo: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
"}}}1

"Detect absence of ColorScheme menu, and generate a new one automatically
if !filereadable(s:menuFile) "{{{
	echomsg "Creating ColorScheme menu - Please Wait..."
	call <SID>InitMenu()
	echomsg "Done!"
endif "}}}

"  vim: tabstop=4 foldmethod=marker
