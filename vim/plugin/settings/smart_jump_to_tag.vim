function! JumpToRubyMethod()
  " Grab the current WORD. Which could be something like
  " object.some_method!
  let l:stuff_under_cursor = expand("<cWORD>")

  " Figure out if this is a method call (obj.some_method)
  " by looking for the period
  let l:method_invocation = split(matchstr(l:stuff_under_cursor, '\..*'), '\.')

  " If there was no method invocation in the current word then
  " we want to avoid the <cWORD> which might be something
  " like foo_bar(baz). We just want the method name, which
  " is already stored for us as <cword> by vim
  if empty(l:method_invocation)
    " See if this is a regular method ending in !
    let l:bang_method = matchstr(l:stuff_under_cursor, '.*!')

    if(empty(l:bang_method))
      let l:method_name = expand("<cword>")
    else
      let l:method_name = l:bang_method
    end
  else
    " If there is a method invocation, then figure out
    " the method name, which is the first element in the match
    let l:method_name = l:method_invocation[0]
  endif

  try
    execute ':tag ' . l:method_name
  catch
  endtry
endfunction

" hit ,f to find the definition of the current class
" this uses ctags. the standard way to get this is Ctrl-]
nnoremap <silent> ,f <C-]>

" Jump to tag with awareness of ruby bang! methods
nnoremap <silent> ,,f :call JumpToRubyMethod()<CR> 

" Jump to tag with awareness of ruby bang! methods (in vertical split)
nnoremap <silent> ,,F :vsp<cr> :wincmd w<cr> :call JumpToRubyMethod()<CR> 

" use ,F to jump to tag in a vertical split
nnoremap <silent> ,F :let word=expand("<cword>")<CR>:vsp<CR>:wincmd w<cr>:exec("tag ". word)<cr>
