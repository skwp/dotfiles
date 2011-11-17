let s:xterm_colors   = [ 0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF ]
let s:eterm_colors   = [ 0x00, 0x2A, 0x55, 0x7F, 0xAA, 0xD4 ]
let s:konsole_colors = [ 0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF ]
let s:xterm_greys    = [ 0x08, 0x12, 0x1C, 0x26, 0x30, 0x3A,
                       \ 0x44, 0x4E, 0x58, 0x62, 0x6C, 0x76,
                       \ 0x80, 0x8A, 0x94, 0x9E, 0xA8, 0xB2,
                       \ 0xBC, 0xC6, 0xD0, 0xDA, 0xE4, 0xEE ]

let s:urxvt_colors   = [ 0x00, 0x8B, 0xCD, 0xFF ]
let s:urxvt_greys    = [ 0x2E, 0x5C, 0x73, 0x8B,
                       \ 0xA2, 0xB9, 0xD0, 0xE7 ]

" Uses &term to determine which cube should be use.  If &term is set to
" "xterm" or begins with "screen", the variables g:CSApprox_eterm and
" g:CSApprox_konsole can be used to select a different palette.
function! csapprox#common#PaletteType()
  if &t_Co == 88
    let type = 'urxvt'
  elseif &term ==# 'xterm' || &term =~# '^screen' || &term==# 'builtin_gui'
    if exists('g:CSApprox_konsole') && g:CSApprox_konsole
      let type = 'konsole'
    elseif exists('g:CSApprox_eterm') && g:CSApprox_eterm
      let type = 'eterm'
    else
      let type = 'xterm'
    endif
  elseif &term =~? '^konsole'
    let type = 'konsole'
  elseif &term =~? '^eterm'
    let type = 'eterm'
  else
    let type = 'xterm'
  endif

  return type
endfunction

" Retrieve the list of greyscale ramp colors for the current palette
function! csapprox#common#Greys()
  return (&t_Co == 88 ? s:urxvt_greys : s:xterm_greys)
endfunction

" Retrieve the list of non-greyscale ramp colors for the current palette
function! csapprox#common#Colors()
  return s:{csapprox#common#PaletteType()}_colors
endfunction
