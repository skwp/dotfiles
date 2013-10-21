"git grep the current word using K (mnemonic Kurrent)
nnoremap <silent> K :call CloseSingleConque()<CR>:GitGrep <cword><CR>

function! GetVisual()
  let reg_save = getreg('"')
  let regtype_save = getregtype('"')
  let cb_save = &clipboard
  set clipboard&
  normal! ""gvy
  let selection = getreg('"')
  call setreg('"', reg_save, regtype_save)
  let &clipboard = cb_save
  return selection
endfunction

"git grep visual selection
vnoremap K :call CloseSingleConque()<CR>:<C-U>execute GitGrep(GetVisual())<CR>

"git grep current word up to the next exclamation point using ,K
nnoremap ,K viwf!:<C-U>execute GitGrep(GetVisual())<CR>

"grep for 'def foo'
nnoremap <silent> ,gd :GitGrep 'def <cword>'<CR>

