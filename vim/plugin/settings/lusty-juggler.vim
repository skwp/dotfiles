" LustyJuggler 
" ========================================
" better triggers for buffer switching
" B to use the a/s/d/f juggler, S to search the buffers
nmap <silent> ,b \lj
nmap <silent> ,s \lb

" Remap using comma for the leader
" lusty file explorer 
nmap <silent> ,lf \lf

" lusty file explorer from current location
nmap <silent> ,lr \lr

" lusty buffer juggler (alternative mapping)
nmap <silent> ,lb \lb

" lusty buffer juggler (alternative mapping)
nmap <silent> ,lj \lj


let g:LustyJugglerSuppressRubyWarning = 1
let g:LustyJugglerAltTabMode = 1
let g:LustyJugglerShowKeys = 'a' " show a/s/d/f keys 
