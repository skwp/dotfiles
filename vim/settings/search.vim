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

"grep the current word using ,k (mnemonic Kurrent)
nnoremap <silent> ,k :Rg <cword><CR>

"grep visual selection
vnoremap ,k :<C-U>execute "Rg " . GetVisual()<CR>

"grep current word up to the next exclamation point using ,K
nnoremap ,K viwf!:<C-U>execute "Rg " . GetVisual()<CR>

"grep for 'def foo'
nnoremap <silent> ,gd :Rg 'def <cword>'<CR>

",gg = Grep! - using Rg RipGrep
" open up a grep line, with a quote started for the search
nnoremap ,gg :Rg ""<left>

"Grep for usages of the current file
nnoremap ,gcf :exec "Rg " . expand("%:t:r")<CR>