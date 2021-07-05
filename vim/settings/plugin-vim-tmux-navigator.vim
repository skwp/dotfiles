" Don't allow any default key-mappings.
let g:tmux_navigator_no_mappings = 1

" Re-enable tmux_navigator.vim default bindings, minus <c-\>.
" <c-\> conflicts with NERDTree "current file".

nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
