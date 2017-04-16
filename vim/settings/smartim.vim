"Default disable smartim
let g:smartim_disable = 1

nnoremap <leader>tsi :call SmartIMToggle()<cr>

function! SmartIMToggle()
    if g:smartim_disable
      let g:smartim_disable = 0
    else
      let g:smartim_disable = 1
    endif
endfunction

function! Multiple_cursors_before()
  let g:smartim_disable = 1
endfunction
function! Multiple_cursors_after()
  "unlet g:smartim_disable
  let g:smartim_disable = 0
endfunction
