" Turn off default key mappings
let g:multi_cursor_use_default_mapping=0

" Switch to multicursor mode with Apple-*
let g:multi_cursor_start_key='<D-*>'

" Ctrl-n, Ctrl-p, Ctrl-x, and <Esc> are mapped in the special multicursor
" mode once you've added at least one virtual cursor to the buffer
let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'
