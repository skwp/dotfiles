" If there isn't one, append a semi colon to the end of the current line.
function! s:appendSemiColon()
  if getline('.') !~ ';$'
    let original_cursor_position = getpos('.')
    exec("s/$/;/")
    call setpos('.', original_cursor_position)
  endif
endfunction

" For programming languages using a semi colon at the end of statement.
autocmd FileType c,cpp,css,java,javascript,perl,php,jade nmap <silent> ;; :call <SID>appendSemiColon()<CR>
autocmd FileType c,cpp,css,java,javascript,perl,php,jade inoremap <silent> ;; <ESC>:call <SID>appendSemiColon()<CR>a

