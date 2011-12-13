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

"idea from : http://www.charlietanksley.net/blog/blog/2011/10/18/vim-navigation-with-lustyexplorer-and-lustyjuggler/
" open lusty file explorer from specific rails-friendly places
map ,lm :LustyFilesystemExplorer app/models<CR>
map ,lc :LustyFilesystemExplorer app/controllers<CR>
map ,lv :LustyFilesystemExplorer app/views<CR>
map ,lh :LustyFilesystemExplorer app/helpers<CR>
map ,ll :LustyFilesystemExplorer lib<CR>
map ,lp :LustyFilesystemExplorer public<CR>
map ,ls :LustyFilesystemExplorer specs<CR>
map ,lt :LustyFilesystemExplorer test<CR>

let g:LustyJugglerSuppressRubyWarning = 1
let g:LustyJugglerAltTabMode = 1
let g:LustyJugglerShowKeys = 'a' " show a/s/d/f keys 
