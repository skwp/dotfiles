" xterm16-v2.43: Vim color scheme file
" Maintainer:	Gautam Iyer <gautam@math.uchicago.edu>
" Created:	Thu 16 Oct 2003 06:17:47 PM CDT
" Modified:	Tue 12 Sep 2006 11:19:35 AM PDT
"
" Adjustable color scheme for GUI/Terminal vim.

let s:cpo_save = &cpo
set cpo&vim		" line continuation is used

hi clear

if exists('syntax_on')
    syntax reset
endif
let colors_name = 'xterm16'

" {{{1 Local function definitions
" {{{2 tohex(n): Convert a number to a 2 digit hex
let s:hex = '0123456789abcdef'
function s:tohex( n)
    return a:n > 255 ? 'ff' : s:hex[a:n / 16] . s:hex[a:n % 16]
endfunction

" {{{2 extractRGB( string): Extract r,g,b components from string into s:c1,2,3
function s:extractRGB( string)
    if a:string =~ '^#[0-9a-f]\{6\}$'
	" Colors in hex values
	let s:c1 = '0x' . strpart(a:string, 1, 2)
	let s:c2 = '0x' . strpart(a:string, 3, 2)
	let s:c3 = '0x' . strpart(a:string, 5, 2)

    elseif a:string =~ '^\d\{3\}$'
	" Colors in cterm values
	let s:c1 = s:guilevel( a:string[0])
	let s:c2 = s:guilevel( a:string[1])
	let s:c3 = s:guilevel( a:string[2])

    elseif a:string =~ '^[lmh][0-9]\{6\}'
	" Colors in propotions of low / med / high
	if exists('s:'.a:string[0])
	    let l:level = s:{a:string[0]}
	    let s:c1 = l:level * strpart(a:string, 1, 2) / 50
	    let s:c2 = l:level * strpart(a:string, 3, 2) / 50
	    let s:c3 = l:level * strpart(a:string, 5, 2) / 50
	else
	    throw 'xterm16 Error: Use of propotional intensities before absolute intensities'
	endif
    else
	throw 'xterm16 Error: Brightness / color "'. a:string . '" badly formed.'
    endif
endfunction

" {{{2 guilevel(n) : Get the gui intensity of a given cterm intensity
function s:guilevel( n)
    return '0x'.s:ccube[2*a:n].s:ccube[2*a:n + 1]
endfunction

" {{{2 ctermlevel(n) : Get the cterm intensity of a given gui intensity
function s:ctermlevel( n)
    " Xterm color cube intensities: 00, 5f, 87, af, d7, ff
    " Rxvt color cube: 00, 2a, 55, 7f, aa, d4

    " cinterval should have the terminal intervals.
    let l:terml = 0
    while l:terml < 5
	if a:n < '0x'.s:cinterval[2 * l:terml].s:cinterval[2 * l:terml + 1]
	    return l:terml
	endif

	let l:terml = l:terml + 1
    endwhile
    return 5
endfunction

" {{{2 guicolor( r, g, b): Return the gui color with intensities r,g,b
function s:guicolor( r, g, b)
    return '#' . s:tohex(a:r) . s:tohex(a:g) . s:tohex(a:b)
endfunction

" {{{2 ctermcolor( r, g, b): Return the xterm-256 color with intensities r, g, b
function s:ctermcolor( r, g, b)
    if a:r == a:g && a:r == a:b
	" Use the greyscale ramp. The greyscale ramp starts from color 232
	" with grey 8, and procedes in increments of 10 upto grey 238 (0xee)
	if a:r <= 4
	    return 16
	elseif a:r <= 243
	    return (a:r - 4) / 10 + 232
	else
	    " Let's check if the last color in ccube is large enough.
	    " return (s:termtype == 'xterm' && a:r > 247) ? 231 : 255
	    let l:l5 = s:guilevel(5)
	    return ( l:l5 > 0xee && a:r > (l:l5 + 0xee)/2 ) ? 231 : 255
	endif
    else
	" Use the rgb cube.
	return s:ctermlevel(a:r) * 36 + s:ctermlevel(a:g) * 6 + s:ctermlevel(a:b) + 16
    endif
endfunction

" {{{2 setcolor( name, r, g, b): Set the script variables gui_name and cterm_name
function s:setcolor( name, r, g, b)
    if exists('g:xterm16_'.a:name)
	" Use user-defined color settings (from global variable)
	call s:extractRGB( g:xterm16_{a:name})

	let s:gui_{a:name} = s:guicolor( s:c1, s:c2, s:c3)
	let s:cterm_{a:name} = s:ctermcolor( s:c1, s:c2, s:c3)
    else
	" Set the GUI / cterm color from r,g,b
	let s:gui_{a:name} = s:guicolor( a:r, a:g, a:b)
	let s:cterm_{a:name} = ( &t_Co == 256 || has('gui_running') )
		    \ ? s:ctermcolor( a:r, a:g, a:b) : a:name
    endif

    " Add the color to palette
    let g:xterm16_palette = g:xterm16_palette . "\n" . s:gui_{a:name} . ', cterm ' . s:cterm_{a:name} . '	: ' . a:name
endfunction

" {{{2 getcolor( group, globalvar, colorname): if globvar exists, returns that
" color. if not returns the color in cname
function s:getcolor( globvar, cname)
    " hopefully someone set ctype before getting here. ctype should either be
    " "gui" or "cterm"

    if exists( a:globvar)
	if exists( 's:'.s:ctype.'_'.{a:globvar})
	    return s:{s:ctype}_{{a:globvar}}
	else
	    call s:extractRGB( {a:globvar})
	    return s:{s:ctype}color( s:c1, s:c2, s:c3)
	endif
    else
	return s:{s:ctype}_{a:cname}
    endif
endfunction

" {{{2 use_guiattr( nattrs, n ): Should s:hi use the n'th attr for GUI hl.
function s:use_guiattr( nattrs, n )
    " If guisp is specified in vim6, then don't use any GUI attributes.
    " Otherwise use GUI attributes if GUI is running and they are specified.
    if !has('gui_running')				||
	    \ a:nattrs < a:n				||
	    \ ( v:version < 700 && a:nattrs >= 4 )
	" Don't use GUI attributes
	return 0
    else
	" Use GUI attributes
	return 1
    endif
endfunction

" {{{2 hi( group, attr, fg, bg): Set the gui/cterm highlighting groups
"
"	group - groupname.
"	attr - attributes.
"	fg/bg color name.
"
" Optionally can call it as
"
" 	hi( group, attr, fg, bg, guiattr, guifg, guibg, guisp )
"
" where all the gui options are optional. If provided, they override the term
" colors.
function s:hi( group, attr, fg, bg, ...)
    if has('gui_running') || &t_Co == 256
	" For gui's and 256 color terminals
	let l:fg = s:getcolor( 'g:xterm16fg_'.a:group,
		    \ s:use_guiattr( a:0, 2) ? a:2 : a:fg)
	let l:bg = s:getcolor( 'g:xterm16bg_'.a:group,
		    \ s:use_guiattr( a:0, 3) ? a:3 : a:bg)

	if exists('g:xterm16attr_' . a:group)
	    let l:attr = g:xterm16attr_{a:group}
	else
	    let l:attr = s:use_guiattr( a:0, 1) ? a:1 : a:attr
	endif

	exec 'hi' a:group
		    \ s:ctype.'='.l:attr
		    \ s:ctype.'fg='.l:fg
		    \ s:ctype.'bg='.l:bg

	" Define guisp if specified for the gui (Vim7 upwards only).
	if v:version >= 700 && has('gui_running') && a:0 >= 4
	    let l:sp = s:getcolor( 'g:xterm16sp_'.a:group, a:4 )
	    exec 'hi' a:group s:ctype.'sp='.l:sp
	endif
    else
	" for consoles / 16 color junkies
	exec 'hi' a:group 'cterm='.a:attr 'ctermfg='.a:fg 'ctermbg='.a:bg
    endif
endfunction

" {{{2 set_brightness( default): Set s:brightness based on default
function s:set_brightness( default)
    let s:brightness = ( exists('g:xterm16_brightness') 
		\ && g:xterm16_brightness != 'default') ?
		\	g:xterm16_brightness : a:default
    if s:colormap == 'allblue'
	if s:brightness == 'high'
	    let s:brightness = '#afafff'	" 335
	elseif  s:brightness == 'med'
	    let s:brightness = '#8787d7'	" 224
	elseif s:brightness == 'low'
	    let s:brightness = '#5f5faf'	" 113
	endif
    elseif s:colormap == 'softlight'
	if s:brightness == 'high'
	    let s:brightness = '#ff87af'	" 523
	elseif  s:brightness == 'med'
	    let s:brightness = '#d75f87'	" 412
	elseif s:brightness == 'low'
	    let s:brightness = '#af5f87'	" 312
	endif
    else
	if s:brightness == 'high'
	    let s:brightness = '#afd7ff'	" 345
	elseif  s:brightness == 'med'
	    let s:brightness = '#87afd7'	" 234
	elseif s:brightness == 'low'
	    let s:brightness = '#5f87af'	" 123
	endif
    endif
endfunction

" {{{1 Global functions and initialisations.
command! -nargs=* Brightness
	    \ if Brightness(<f-args>)	<bar>
	    \	colo xterm16		<bar>
	    \ endif

" {{{2 Brightness( brightness, colormap)
function! Brightness(...)
    if a:0 == 0
	echo "Brightness: ".s:brightness.", Colormap: ".s:colormap
	return 0
    elseif a:0 > 2
	echoerr 'Too many arguements.'
	return 0
    endif

    let g:xterm16_brightness = a:1
    if a:0 == 2
	let g:xterm16_colormap = a:2
    endif

    return 1
endfunction
" }}}1

try
    " {{{1 Setup defaults
    " {{{2 set ctype (to cterm / gui) to be the color type
    let s:ctype = has('gui_running') ? 'gui' : 'cterm'
    " {{{2 Obtain intensity levels of the 6 terminal colors in s:ccube
    " The 2ith and 2i+1th charecters in ccube are the hex digits of the
    " intensity of the ith (0-5) term level. xterm and rxvt set up the default
    " color cube differently, so we have to consider them separately.

    " First check for a user specified color cube.
    if exists('g:xterm16_ccube')
	let s:ccube = g:xterm16_ccube

    " No user specified color cube given. Try and guess from xterm16_termtype
    elseif ( exists('g:xterm16_termtype') && g:xterm16_termtype == 'rxvt') ||
		\ ( !exists('g:xterm16_termtype')
		\	&& &term =~ '^rxvt'
		\	&& $MRXVT_TABTITLE == "" )
	" color cube for "rxvt". Make sure we're not running mrxvt (by
	" checking that the MRXVT_TABTITLE variable is empty).
	let s:ccube = "002a557faad4"
    else
	" default to xterm if nothing else is specified.
	let s:ccube ="005f87afd7ff"
    endif

    " s:cinterval will be the intervals of intensities which get mapped to
    " term color i. i.e. colors between 0 -- cinterval(0) have level 0.
    " between cinterval(0) -- cinterval(1) have level 1, etc. max level is 5,
    " so anything higher than cinterval(4) has level 5.
    let s:cinterval = ""
    let s:lower	= "00"
    let s:i = 1
    while s:i < 6
	let s:upper = s:ccube[2*s:i] . s:ccube[2*s:i + 1]
	let s:cinterval = s:cinterval . s:tohex( (('0x'.s:lower) + ('0x'.s:upper))/2 )
	let s:lower = s:upper
	let s:i = s:i + 1
    endwhile

    " {{{2 Get colormap defaults in "s:colormap"
    " On a terminal (without 256 colors), use "standard" colormap. Otherwise
    " use value from "g:xterm16_colormap" if exists, or "soft" as default.
    if !has('gui_running') && &t_Co != 256
	let s:colormap = 'standard'
    elseif exists('g:xterm16_colormap')
	let s:colormap = g:xterm16_colormap
    else
	" "soft" used to be the default, but "allblue" is much better.
	let s:colormap = 'allblue'
    endif

    " {{{2 Redefine a few colors for CRT monitors and set brightness
    if s:colormap == 'allblue'
	call s:set_brightness( '#8787d7' )	" 224
    elseif s:colormap == 'softlight'
	call s:set_brightness( '#d75f87' )	" 412
    elseif exists('g:xterm16_CRTColors')
	" "standard" or "soft" colormaps
	if s:colormap == 'standard'
	    let g:xterm16_darkblue	= 'h000050'
	    let g:xterm16_blue		= 'h002550'
	    let g:xterm16_grey		= 'm474747'

	    unlet! g:xterm16_skyblue g:xterm16_green g:xterm16_bluegreen

	    " give the original xterm16 feel
	    call s:set_brightness( '#80cdff')
	else
	    " "soft" colormap
	    let g:xterm16_skyblue	= 'h003850'
	    let g:xterm16_green		= 'm315000'
	    let g:xterm16_bluegreen	= 'm005031'

	    unlet! g:xterm16_darkblue g:xterm16_blue g:xterm16_grey

	    " call s:set_brightness ( '245')
	    " call s:set_brightness('high')
	    call s:set_brightness('#87d7ff') " 245
	endif
    else
	" "standard" or "soft" colormaps with LCD colors
	call s:set_brightness( '#5fafd7') " 134
    endif

    unlet! s:c1 s:c2 s:c3
    call s:extractRGB(s:brightness)
    let s:l = s:c1
    let s:m = s:c2
    let s:h = s:c3

    " {{{2 Set a bright green cursor on all colormaps except softlight
    if !exists('g:xterm16bg_Cursor')
	if s:colormap == 'softlight'
	    let g:xterm16fg_Cursor		= '#ffffff'
	else
	    let g:xterm16bg_Cursor		= '#00ff00'
	endif
    endif

    " {{{2 Set the current pallete:
    let g:xterm16_palette = 'Current palette (Brightness: '.s:brightness. ', Colormap: '.s:colormap.')'

    " {{{1 Define colors and highlighting groups based on "s:colormap"
    let s:cterm_none = 'NONE'
    let s:gui_none = 'NONE'

    " Set the background based on the colormap. 'softlight' is the only
    " colormap with a light background
    if s:colormap == 'softlight'
	set bg=light
    else
	set bg=dark
    endif

    if s:colormap == 'standard'
	" {{{2 Original colormap. 8 standard colors, and 8 brighter ones.
	call s:setcolor( 'black',       0        , 0        , 0        )
	call s:setcolor( 'darkred',     s:m      , 0        , 0        )
	call s:setcolor( 'darkgreen',   0        , s:m      , 0        )
	call s:setcolor( 'darkyellow',  s:m      , s:m      , 0        )
	call s:setcolor( 'darkblue',    0        , 0        , s:m      )
	call s:setcolor( 'darkmagenta', s:m      , 0        , s:m      )
	call s:setcolor( 'darkcyan',    0        , s:m      , s:m      )
	call s:setcolor( 'grey',        s:m*44/50, s:m*44/50, s:m*44/50)

	call s:setcolor( 'darkgrey',    s:l      , s:l      , s:l      )
	call s:setcolor( 'red',         s:h      , 0        , 0        )
	call s:setcolor( 'green',       0        , s:h      , 0        )
	call s:setcolor( 'yellow',      s:h      , s:h      , 0        )
	call s:setcolor( 'blue',        0        , 0        , s:h      )
	call s:setcolor( 'magenta',     s:h      , 0        , s:h      )
	call s:setcolor( 'cyan',        0        , s:h      , s:h      )
	call s:setcolor( 'white',       s:h      , s:h      , s:h      )

	" {{{2 Highlighting groups for standard colors
	call s:hi( 'Normal'      , 'none'   , 'grey'       , 'black'     )

	call s:hi( 'Cursor'      , 'none'   , 'black'      , 'green'     )
	call s:hi( 'CursorColumn', 'none'   , 'none'       , 'darkgrey'  )
	call s:hi( 'CursorLine'  , 'none'   , 'none'       , 'darkgrey'  )
	call s:hi( 'DiffAdd'     , 'none'   , 'darkblue'   , 'darkgreen' )
	call s:hi( 'DiffChange'  , 'none'   , 'black'      , 'darkyellow')
	call s:hi( 'DiffDelete'  , 'none'   , 'darkblue'   , 'none'      )
	call s:hi( 'DiffText'    , 'none'   , 'darkred'    , 'darkyellow')
	call s:hi( 'Directory'   , 'none'   , 'cyan'       , 'none'      )
	call s:hi( 'ErrorMsg'    , 'none'   , 'white'      , 'darkred'   )
	call s:hi( 'FoldColumn'  , 'none'   , 'yellow'     , 'darkblue'  )
	call s:hi( 'Folded'      , 'none'   , 'yellow'     , 'darkblue'  )
	call s:hi( 'IncSearch'   , 'none'   , 'grey'       , 'darkblue'  )
	call s:hi( 'LineNr'      , 'none'   , 'yellow'     , 'none'      )
	call s:hi( 'MatchParen'  , 'bold'   , 'none'       , 'none'      )
	call s:hi( 'MoreMsg'     , 'bold'   , 'green'      , 'none'      )
	call s:hi( 'NonText'     , 'none'   , 'blue'       , 'none'      )
	call s:hi( 'Pmenu'       , 'none'   , 'black'      , 'grey'      )
	call s:hi( 'PmenuSel'    , 'none'   , 'none'       , 'darkblue'  )
	call s:hi( 'PmenuSbar'   , 'none'   , 'none'       , 'darkgrey'  )
	call s:hi( 'PmenuThumb'  , 'none'   , 'none'       , 'white'     )
	call s:hi( 'Question'    , 'none'   , 'green'      , 'none'      )
	call s:hi( 'Search'      , 'none'   , 'black'      , 'darkcyan'  )
	call s:hi( 'SignColumn'  , 'none'   , 'darkmagenta', 'darkgrey'  )
	call s:hi( 'SpecialKey'  , 'none'   , 'blue'       , 'none'      )
	call s:hi( 'StatusLine'  , 'none'   , 'darkblue'   , 'grey'      )
	call s:hi( 'StatusLineNC', 'reverse', 'none'       , 'none'      )
	call s:hi( 'TabLineFill' , 'none'   , 'black'	   , 'darkgrey'	 )
	call s:hi( 'TabLine'	 , 'none'   , 'black'	   , 'darkgrey'	 )
	call s:hi( 'TabLineSel'  , 'bold'   , 'none'	   , 'none'	 )
	call s:hi( 'Title'       , 'none'   , 'magenta'    , 'none'      )
	call s:hi( 'Visual'      , 'none'   , 'none'       , 'darkblue'  )
	call s:hi( 'VisualNOS'   , 'none'   , 'none'       , 'darkgrey'  )
	call s:hi( 'WarningMsg'  , 'bold'   , 'red'        , 'none'      )
	call s:hi( 'WildMenu'    , 'none'   , 'darkmagenta', 'darkyellow')

	call s:hi( 'Comment'      , 'none'  , 'darkred'    , 'none'      )
	call s:hi( 'Constant'     , 'none'  , 'darkyellow' , 'none'      )
	call s:hi( 'Error'        , 'none'  , 'white'      , 'red'       )
	call s:hi( 'Identifier'   , 'none'  , 'darkcyan'   , 'none'      )
	call s:hi( 'Ignore'       , 'none'  , 'darkgrey'   , 'none'      )
	call s:hi( 'PreProc'      , 'none'  , 'blue'       , 'none'      )
	call s:hi( 'Special'      , 'none'  , 'darkgreen'  , 'none'      )
	call s:hi( 'Statement'    , 'none'  , 'cyan'       , 'none'      )
	call s:hi( 'Todo'         , 'none'  , 'black'      , 'yellow'    )
	call s:hi( 'Type'         , 'none'  , 'green'      , 'none'      )
	call s:hi( 'Underlined'   , 'none'  , 'darkmagenta', 'none'      )

	" {{{2 Spelling highlighting groups.
	call s:hi( 'SpellBad'  , 'bold,underline', 'none', 'none'    ,
		    \		 'undercurl'     , 'none', 'none'    ,
		    \            'darkred'       )
	call s:hi( 'SpellCap'  , 'bold'          , 'none', 'none'    ,
		    \		 'undercurl'     , 'none', 'none'    ,
		    \            'blue'          )
	call s:hi( 'SpellLocal', 'underline'     , 'none', 'none'    ,
		    \		 'undercurl'     , 'none', 'none'    ,
		    \            'cyan'          )
	call s:hi( 'SpellRare'	,'underline'     , 'none', 'none'    ,
		    \		 'undercurl'     , 'none', 'none'    ,
		    \            'darkyellow'    )

	" {{{2 Define html highlighting groups for standard colors.
	if !exists("g:xterm16_NoHtmlColors")
	    call s:hi( 'htmlBold',                'none', 'white',       'none', 'bold',                  'none')
	    call s:hi( 'htmlItalic',              'none', 'yellow',      'none', 'italic',                'none')
	    call s:hi( 'htmlUnderline',           'none', 'darkmagenta', 'none', 'underline',             'none')
	    call s:hi( 'htmlBoldItalic',          'bold', 'yellow',      'none', 'bold,italic',           'none')
	    call s:hi( 'htmlBoldUnderline',       'bold', 'magenta',     'none', 'bold,underline',        'none')
	    call s:hi( 'htmlUnderlineItalic',     'none', 'magenta',     'none', 'underline,italic',      'none')
	    call s:hi( 'htmlBoldUnderlineItalic', 'bold', 'white',       'none', 'bold,underline,italic', 'none')

	    hi! link htmlLink PreProc
	endif
	" {{{2 Remap darkblue on linux consoles
	if !exists("g:xterm16_NoRemap") && &term =~# (exists("g:xterm16_TermRegexp") ? xterm16_TermRegexp : "linux")
	    hi! link PreProc		Underlined
	endif
	" }}}2
    elseif s:colormap == 'soft' || s:colormap == 'softlight'
	" {{{2 "soft" / "softlight" colormap.
	" Mix and use similar intensity colors. Only drawback is a slightly
	" gaudy appearance (which is why I switched to the "allblue"
	" colormap).
	"
	" The "softlight" colormap is a colormap with a whiteish background
	" for web hosting or when there's a strong glare ...

	" Background colors common to softlight / soft colormaps
	call s:setcolor( 'black'      , 0         , 0         , 0         )

	" call s:setcolor( 'grey'       , s:l/2    , s:l/2   , s:l/2    )
	" call s:setcolor( 'lightgrey'  , 2*s:l/3  , 2*s:l/3 , 2*s:l/3  )

	" Foreground colors common to softlight / soft colormaps
	call s:setcolor( 'lightbrown' , s:h       , s:h/2     , 0         )
	call s:setcolor( 'magenta'    , s:h*3/4   , 0         , s:h       )
	call s:setcolor( 'red'        , s:h       , 0         , 0         )
	call s:setcolor( 'yellow'     , s:m       , s:m       , 0         )

	if s:colormap == "soft"
	    " Background colors for colormap with a dark background
	    call s:setcolor( 'darkblue'  , 0         , 0         , s:l       )
	    call s:setcolor( 'darkcyan'  , 0         , s:l       , s:l       )
	    call s:setcolor( 'darkred'   , s:l       , 0         , 0         )
	    call s:setcolor( 'darkyellow', s:l       , s:l       , 0         )
	    call s:setcolor( 'darkgrey'  , s:l/3     , s:l/3     , s:l/3     )
	    call s:setcolor( 'grey'      , s:l/2     , s:l/2     , s:l/2     )
	    call s:setcolor( 'lightgrey' , s:l       , s:l       , s:l       )

	    " Foreground colors for colormap with a dark background
	    call s:setcolor( 'bluegreen' , 0         , s:m       , s:m*38/50 )
	    call s:setcolor( 'cyan'      , 0         , s:m       , s:m       )
	    call s:setcolor( 'green'     , s:m*38/50 , s:m       , 0         )
	    call s:setcolor( 'purple'    , s:h*27/50 , s:h*27/50 , s:h       )
	    call s:setcolor( 'skyblue'   , 0         , s:h*27/50 , s:h       )
	    call s:setcolor( 'white'     , s:m*44/50 , s:m*44/50 , s:m*44/50 )
	else
	    " Background colors for colormap with a light background
	    call s:setcolor( 'darkblue'  , s:l*27/50 , s:l*27/50 , s:l       )
	    call s:setcolor( 'darkcyan'  , s:l*27/50 , s:l*38/50 , s:l       )
	    call s:setcolor( 'darkred'   , s:l       , s:l*27/50 , s:l*27/50 )
	    call s:setcolor( 'darkyellow', s:l       , s:l       , s:l*27/50 )
	    call s:setcolor( 'darkgrey'  , s:l*40/50 , s:l*40/50 , s:l*40/50 )
	    call s:setcolor( 'grey'      , s:l*35/50 , s:l*35/50 , s:l*35/50 )
	    call s:setcolor( 'lightgrey' , s:l*30/50 , s:l*30/50 , s:l*30/50 )

	    call s:setcolor( 'white'     , s:l*45/50 , s:l*45/50 , s:l*45/50 )

	    " Foreground colors for colormap with a light background
	    call s:setcolor( 'bluegreen' , 0         , s:h       , 0         )
	    call s:setcolor( 'cyan'      , 0         , s:h*38/50 , s:h       )
	    call s:setcolor( 'green'     , 0         , s:m       , 0         )
	    call s:setcolor( 'purple'    , s:h*38/50 , 0         , s:h       )
	    call s:setcolor( 'skyblue'   , 0         , 0         , s:h       )
	endif

	" {{{2 Highlighting groups for "soft" / "softlight" colors.
	if s:colormap == 'soft'
	    " Highlighting groups for dark background
	    call s:hi( 'Normal'      , 'none', 'white'    , 'black'     )

	    call s:hi( 'Cursor'      , 'none', 'black'    , 'green'     )
	    call s:hi( 'DiffText'    , 'none', 'darkred'  , 'darkyellow')
	    call s:hi( 'Error'       , 'none', 'white'    , 'darkred'   )
	    call s:hi( 'ErrorMsg'    , 'none', 'white'    , 'darkred'   )
	    call s:hi( 'FoldColumn'  , 'none', 'purple'   , 'darkgrey'  )
	    call s:hi( 'Folded'      , 'none', 'purple'   , 'darkgrey'  )
	    call s:hi( 'IncSearch'   , 'none', 'yellow'   , 'darkblue'  )
	    call s:hi( 'StatusLine'  , 'none', 'darkblue' , 'lightgrey' )
	    call s:hi( 'VisualNOS'   , 'none', 'black'    , 'darkgrey'  )
	else
	    " Highlighting groups for light background
	    call s:hi( 'Normal'      , 'none', 'black'    , 'white'     )

	    call s:hi( 'Cursor'      , 'none', 'white'    , 'bluegreen' )
	    call s:hi( 'DiffText'    , 'none', 'red'      , 'darkyellow')
	    call s:hi( 'Error'       , 'none', 'black'    , 'darkred'   )
	    call s:hi( 'ErrorMsg'    , 'none', 'white'    , 'red'       )
	    call s:hi( 'FoldColumn'  , 'none', 'lightgrey', 'darkgrey'  )
	    call s:hi( 'Folded'      , 'none', 'black'    , 'darkgrey'  )
	    call s:hi( 'IncSearch'   , 'none', 'black'    , 'darkblue'  )
	    call s:hi( 'StatusLine'  , 'none', 'skyblue'  , 'lightgrey' )
	    call s:hi( 'VisualNOS'   , 'none', 'white'    , 'darkgrey'  )
	endif

	" Highlighting groups for light / dark background.
	call s:hi( 'CursorColumn', 'none', 'none'      , 'grey'      )
	call s:hi( 'CursorLine'  , 'none', 'none'      , 'grey'      )
	call s:hi( 'DiffAdd'     , 'none', 'lightbrown', 'darkblue'  )
	call s:hi( 'DiffChange'  , 'none', 'black'     , 'darkyellow')
	call s:hi( 'DiffDelete'  , 'none', 'purple'    , 'darkblue'  )
	call s:hi( 'Directory'   , 'none', 'cyan'      , 'none'      )
	call s:hi( 'LineNr'      , 'none', 'yellow'    , 'none'      )
	call s:hi( 'MatchParen'  , 'bold', 'none'      , 'none'      )
	call s:hi( 'MoreMsg'     , 'none', 'green'     , 'none'      )
	call s:hi( 'NonText'     , 'none', 'yellow'    , 'none'      )
	call s:hi( 'Pmenu'       , 'none', 'none'      , 'grey'      )
	call s:hi( 'PmenuSbar'   , 'none', 'none'      , 'darkgrey'  )
	call s:hi( 'PmenuSel'    , 'none', 'none'      , 'darkblue'  )
	call s:hi( 'PmenuThumb'  , 'none', 'none'      , 'lightgrey' )
	call s:hi( 'Question'    , 'none', 'green'     , 'none'      )
	call s:hi( 'Search'      , 'none', 'black'     , 'darkcyan'  )
	call s:hi( 'SignColumn'  , 'none', 'yellow'    , 'darkgrey'  )
	call s:hi( 'SpecialKey'  , 'none', 'yellow'    , 'none'      )
	call s:hi( 'StatusLineNC', 'none', 'black'     , 'grey'      )
	call s:hi( 'TabLineFill' , 'none', 'none'      , 'grey'	     )
	call s:hi( 'TabLine'     , 'none', 'none'      , 'grey'	     )
	call s:hi( 'TabLineSel'  , 'bold', 'none'      , 'none'	     )
	call s:hi( 'Title'       , 'none', 'yellow'    , 'none'      )
	call s:hi( 'VertSplit'   , 'none', 'darkgrey'  , 'darkgrey'  )
	call s:hi( 'Visual'      , 'none', 'none'      , 'darkblue'  )
	call s:hi( 'WarningMsg'  , 'none', 'red'       , 'none'      )
	call s:hi( 'WildMenu'    , 'none', 'yellow'    , 'none'      )

	call s:hi( 'Comment'     , 'none', 'red'       , 'none'      )
	call s:hi( 'Constant'    , 'none', 'lightbrown', 'none'      )
	call s:hi( 'Identifier'  , 'none', 'cyan'      , 'none'      )
	call s:hi( 'Ignore'      , 'none', 'darkgrey'  , 'none'      )
	call s:hi( 'PreProc'     , 'none', 'purple'    , 'none'      )
	call s:hi( 'Special'     , 'none', 'green'     , 'none'      )
	call s:hi( 'Statement'   , 'none', 'skyblue'   , 'none'      )
	call s:hi( 'Todo'        , 'none', 'black'     , 'darkyellow')
	call s:hi( 'Type'        , 'none', 'bluegreen' , 'none'      )
	call s:hi( 'Underlined'  , 'none', 'magenta'   , 'none'      )

	" {{{2 Spelling highlighting groups.
	call s:hi( 'SpellBad'  , 'bold,underline', 'none', 'darkgrey',
		    \		 'undercurl'     , 'none', 'none'    ,
		    \            'red'           )
	call s:hi( 'SpellCap'  , 'bold'          , 'none', 'darkgrey',
		    \		 'undercurl'     , 'none', 'none'    ,
		    \            'skyblue'       )
	call s:hi( 'SpellLocal', 'underline'     , 'none', 'darkgrey',
		    \		 'undercurl'     , 'none', 'none'    ,
		    \            'cyan'          )
	call s:hi( 'SpellRare'	,'underline'     , 'none', 'none'    ,
		    \		 'undercurl'     , 'none', 'none'    ,
		    \            'yellow'        )

	" {{{2 Define html highlighting groups for soft colors.
	if !exists("g:xterm16_NoHtmlColors")
	    call s:hi( 'htmlBold',                'none', 'yellow',  'none',
			\ 'bold',                  'none')
	    call s:hi( 'htmlItalic',              'none', 'yellow',  'none',
			\ 'italic',                'none')
	    call s:hi( 'htmlUnderline',           'none', 'magenta', 'none',
			\ 'underline',             'none')
	    call s:hi( 'htmlBoldItalic',          'bold', 'yellow',  'none',
			\ 'bold,italic',           'none')
	    call s:hi( 'htmlBoldUnderline',       'bold', 'magenta', 'none',
			\ 'bold,underline',        'none')
	    call s:hi( 'htmlUnderlineItalic',     'bold', 'magenta', 'none',
			\ 'underline,italic',      'none')
	    call s:hi( 'htmlBoldUnderlineItalic', 'bold', 'white',   'none',
			\ 'bold,underline,italic', 'none')
	endif
	" }}}2
    elseif s:colormap == 'allblue'
	" {{{2 "allblue" colormap. All shades of blue.
	" Background colors
	call s:setcolor( 'black'      , 0         , 0        , 0           )
	call s:setcolor( 'darkred'    , s:l       , 0        , 0           )
	call s:setcolor( 'darkcyan'   , 0         , s:l      , s:l         )
	call s:setcolor( 'darkblue'   , 0         , 0        , s:l         )
	call s:setcolor( 'darkyellow' , s:l       , s:l      , 0           )

	" cterm's can do grey's with better accuracy, so use many shades of
	" grey for backgrounds instead of the gaudy yellow's etc.
	call s:setcolor( 'grey1'      , s:l/8     , s:l/8     , s:l/8      )
	call s:setcolor( 'grey2'      , 2*s:l/8   , 2*s:l/8   , 2*s:l/8    )
	call s:setcolor( 'grey3'      , 3*s:l/8   , 3*s:l/8   , 3*s:l/8    )
	call s:setcolor( 'grey4'      , 4*s:l/8   , 4*s:l/8   , 4*s:l/8    )
	call s:setcolor( 'grey5'      , 5*s:l/8   , 5*s:l/8   , 5*s:l/8    )
	" call s:setcolor( 'grey6'      , 6*s:l/8   , 6*s:l/8   , 6*s:l/8    )
	" call s:setcolor( 'grey7'      , 7*s:l/8   , 7*s:l/8   , 7*s:l/8    )
	call s:setcolor( 'grey'       , s:l       , s:l       , s:l        )

	" Foreground colors:
	"
	" 	s:m -- lowest intensity level for fg colors
	" 	s:h -- highest intensity level.
	" 	s:M -- medium intensity (average of the above two)

	let s:M = (s:m + s:h) / 2

	call s:setcolor( 'red'        , s:h       , 0         , 0          )
	call s:setcolor( 'lightbrown' , s:M       , s:m       , 0          )
	call s:setcolor( 'yellow'     , s:M       , s:M       , s:m        )
	call s:setcolor( 'dirtygreen' , s:m       , s:m       , 0          )
	call s:setcolor( 'green'      , s:m       , s:M       , s:m        )
	call s:setcolor( 'bluegreen'  , 0         , s:M       , s:m        )
	call s:setcolor( 'yellowgreen', s:m       , s:M       , 0          )
	call s:setcolor( 'skyblue'    , 0         , s:m       , s:M        )
	call s:setcolor( 'lightblue'  , 0         , s:m       , s:h        )
	call s:setcolor( 'cyan'       , 0         , s:M       , s:M        )
	call s:setcolor( 'lightcyan'  , s:m       , s:M       , s:M        )
	call s:setcolor( 'darkpurple' , s:m       , 0         , s:h        )
	call s:setcolor( 'purple'     , s:m       , s:m       , s:M        )

	" Unused colors that are pretty reasonable
	" call s:setcolor( 'lightred'   , s:M       , s:m       , s:m        )
	" call s:setcolor( 'bluewhite'  , s:M       , s:M       , s:h        )
	" call s:setcolor( 'lightpurple', s:m       , s:m       , s:h        )

	" Greys can be done with better accurcy on cterms!
	call s:setcolor( 'white'      , 48*s:M/50 , 48*s:M/50 , 48*s:M/50  )
	call s:setcolor( 'white1'     , 40*s:M/50 , 40*s:M/50 , 40*s:M/ 50 )

	unlet s:M

	" {{{2 Highlighting groups for "allblue" colors.
	call s:hi( 'Normal'       , 'none'   , 'white'       , 'black'      )

	call s:hi( 'Cursor'       , 'none'   , 'black'       , 'green'      )
	call s:hi( 'CursorColumn' , 'none'   , 'none'        , 'grey4'      )
	call s:hi( 'CursorLine'   , 'none'   , 'none'        , 'grey4'      )
	call s:hi( 'DiffAdd'      , 'none'   , 'lightbrown'  , 'grey2'      )
	call s:hi( 'DiffChange'   , 'none'   , 'yellow'      , 'grey2'      )
	call s:hi( 'DiffDelete'   , 'none'   , 'dirtygreen'  , 'grey2'      )
	call s:hi( 'DiffText'     , 'none'   , 'yellowgreen' , 'grey2'      )
	call s:hi( 'Directory'    , 'none'   , 'lightblue'   , 'none'       )
	call s:hi( 'ErrorMsg'     , 'none'   , 'white'       , 'darkred'    )
	call s:hi( 'FoldColumn'   , 'none'   , 'grey4'       , 'none'       )
	call s:hi( 'Folded'       , 'none'   , 'white1'      , 'grey2'      )
	call s:hi( 'IncSearch'    , 'none'   , 'white'       , 'darkblue'   )
	call s:hi( 'LineNr'       , 'none'   , 'yellow'      , 'none'       )
	call s:hi( 'MatchParen'   , 'bold'   , 'none'        , 'none'       )
	call s:hi( 'ModeMsg'      , 'bold'   , 'none'        , 'none'       )
	call s:hi( 'MoreMsg'      , 'none'   , 'green'       , 'none'       )
	call s:hi( 'NonText'      , 'none'   , 'lightbrown'  , 'none'       )
	call s:hi( 'Pmenu'        , 'none'   , 'none'        , 'grey3'      )
	call s:hi( 'PmenuSel'     , 'none'   , 'none'        , 'darkblue'   )
	call s:hi( 'PmenuSbar'    , 'none'   , 'none'        , 'grey2'      )
	call s:hi( 'PmenuThumb'   , 'none'   , 'none'        , 'grey4'      )
	call s:hi( 'Question'     , 'none'   , 'green'       , 'none'       )
	call s:hi( 'Search'       , 'none'   , 'black'       , 'darkcyan'   )
	call s:hi( 'SignColumn'   , 'none'   , 'yellow'      , 'grey1'      )
	call s:hi( 'SpecialKey'   , 'none'   , 'yellow'      , 'none'       )
	call s:hi( 'StatusLineNC' , 'none'   , 'grey'        , 'grey3'      )
	call s:hi( 'StatusLine'   , 'none'   , 'white'       , 'grey5'      )
	call s:hi( 'TabLine'      , 'none'   , 'none'        , 'grey3'      )
	call s:hi( 'TabLineFill'  , 'none'   , 'none'        , 'grey3'      )
	call s:hi( 'TabLineSel'   , 'bold'   , 'none'        , 'none'       )
	call s:hi( 'Title'        , 'none'   , 'yellow'      , 'none'       )
	call s:hi( 'VertSplit'    , 'none'   , 'grey3'       , 'grey3'      )
	call s:hi( 'Visual'       , 'none'   , 'none'        , 'darkblue'   )
	call s:hi( 'VisualNOS'    , 'none'   , 'none'        , 'grey2'      )
	call s:hi( 'WarningMsg'   , 'none'   , 'red'         , 'none'       )
	call s:hi( 'WildMenu'     , 'none'   , 'yellow'      , 'none'       )

	call s:hi( 'Comment'      , 'none'   , 'purple'      , 'none'       )
	call s:hi( 'Constant'     , 'none'   , 'lightcyan'   , 'none'       )
	call s:hi( 'Error'        , 'none'   , 'red'         , 'none'       )
	call s:hi( 'Identifier'   , 'none'   , 'cyan'        , 'none'       )
	call s:hi( 'Ignore'       , 'none'   , 'grey3'       , 'none'       )
	call s:hi( 'PreProc'      , 'none'   , 'darkpurple'  , 'none'       )
	call s:hi( 'Special'      , 'none'   , 'bluegreen'   , 'none'       )
	call s:hi( 'Statement'    , 'none'   , 'skyblue'     , 'none'       )
	call s:hi( 'Todo'         , 'none'   , 'lightbrown'  , 'none'       )
	call s:hi( 'Type'         , 'none'   , 'green'       , 'none'       )
	call s:hi( 'Underlined'   , 'none'   , 'darkpurple'  , 'none'       )

	" {{{2 Spelling highlighting groups.
	"
	" The undercurl looks great in gui, so let's use that. For cterm use
	" some crappy grey background + bold / etc. Not something that stands
	" out too much because there are invariably numerous spelling mistakes
	" highlighted in most code.
	"
	call s:hi( 'SpellBad'	, 'bold,underline'      , 'none', 'grey2',
		    \		  'undercurl' , 'none', 'none' , 'red' 	     )
	call s:hi( 'SpellCap'	, 'bold'      , 'none', 'grey2',
		    \		  'undercurl' , 'none', 'none' , 'skyblue'   )
	call s:hi( 'SpellLocal'	, 'underline' , 'none', 'grey2',
		    \		  'undercurl' , 'none', 'none' , 'lightcyan' )
	call s:hi( 'SpellRare'	, 'underline' , 'none', 'none' ,
		    \		  'undercurl' , 'none', 'none' , 'yellow'    )

	" {{{2 Highlighting groups for email.
	"
	" mailURL links to Constant, which is light cyan. This does not stand
	" out well in quoted emails (which is cyan), or regular text. Better
	" to use light brown (like the soft colormap).
	hi link mailURL		Todo

	" {{{2 Define html highlighting groups for "allblue" colors
	if !exists("g:xterm16_NoHtmlColors")
	    call s:hi( 'htmlBold',                'none', 'yellow',  'none', 'bold',                  'none')
	    call s:hi( 'htmlItalic',              'none', 'yellow',  'none', 'italic',                'none')
	    call s:hi( 'htmlUnderline',           'none', 'darkpurple', 'none', 'underline',             'none')
	    call s:hi( 'htmlBoldItalic',          'bold', 'yellow',  'none', 'bold,italic',           'none')
	    call s:hi( 'htmlBoldUnderline',       'bold', 'darkpurple', 'none', 'bold,underline',        'none')
	    call s:hi( 'htmlUnderlineItalic',     'bold', 'darkpurple', 'none', 'underline,italic',      'none')
	    call s:hi( 'htmlBoldUnderlineItalic', 'bold', 'white',   'none', 'bold,underline,italic', 'none')
	endif
	" }}}2
    else
	throw 'xterm16 Error: Unrecognised colormap "' . s:colormap . '"'
    endif
    " }}}1
catch /^xterm16 Error:/
    " {{{1 Handle internal exceptions.
    unlet colors_name

    echohl ErrorMsg
    echomsg v:exception
    echohl None
    " }}}1
finally
    " {{{1 Unlet script variables and functions
    " Restore compatibility options
    let &cpo = s:cpo_save
    unlet! s:c1 s:c2 s:c3
    unlet! s:i s:lower s:upper s:ccube s:cinterval
    unlet! s:cpo_save s:hex s:l s:m s:h s:cterm_none s:gui_none

    " Delete colors of "standard" colormap
    unlet! s:gui_black s:gui_darkred s:gui_darkgreen s:gui_darkyellow s:gui_darkblue s:gui_darkmagenta s:gui_darkcyan s:gui_grey s:gui_darkgrey s:gui_red s:gui_green s:gui_yellow s:gui_blue s:gui_magenta s:gui_cyan s:gui_white
    unlet! s:cterm_black s:cterm_darkred s:cterm_darkgreen s:cterm_darkyellow s:cterm_darkblue s:cterm_darkmagenta s:cterm_darkcyan s:cterm_grey s:cterm_darkgrey s:cterm_red s:cterm_green s:cterm_yellow s:cterm_blue s:cterm_magenta s:cterm_cyan s:cterm_white

    " Delete extra colors of "soft" colormap
    unlet! s:gui_lightbrown s:gui_bluegreen s:gui_skyblue s:gui_purple
    unlet! s:cterm_lightbrown s:cterm_bluegreen s:cterm_skyblue s:cterm_purple

    " Delete extra colors from "allblue" colormap
    unlet! s:gui_darkcyan s:gui_darkblue s:gui_grey1 s:gui_grey2 s:gui_grey3 s:gui_grey4 s:gui_grey5 s:gui_white1 s:gui_dirtygreen s:gui_yellowgreen s:gui_lightblue s:gui_lightcyan s:gui_darkpurple
    unlet! s:cterm_darkcyan s:cterm_darkblue s:cterm_grey1 s:cterm_grey2 s:cterm_grey3 s:cterm_grey4 s:cterm_grey5 s:cterm_white1 s:cterm_dirtygreen s:cterm_yellowgreen s:cterm_lightblue s:cterm_lightcyan s:cterm_darkpurple

    delfunction s:tohex
    delfunction s:extractRGB
    delfunction s:guilevel
    delfunction s:ctermlevel
    delfunction s:guicolor
    delfunction s:ctermcolor
    delfunction s:setcolor
    delfunction s:getcolor
    delfunction s:use_guiattr
    delfunction s:hi
    delfunction s:set_brightness
    " }}}1
endtry
