" via: http://rails-bestpractices.com/posts/60-remove-trailing-whitespace
" Strip trailing whitespace
function! <SID>StripTrailingWhitespaces()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
    " TT additions, will exit insert
    stopinsert
endfunction

command! StripTrailingWhitespaces call <SID>StripTrailingWhitespaces()
nmap ,w :StripTrailingWhitespaces<CR>

" TT additions
autocmd BufWritePre *rb,*js,*haml,*html,*erb,*vim :call <SID>StripTrailingWhitespaces()
