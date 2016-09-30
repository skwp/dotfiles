let g:nerdtree_tabs_open_on_gui_startup = 1
" Auto open nerd tree on startup if directory supplied as arguments
let g:nerdtree_tabs_open_on_console_startup = 2
" Focus in the main content window
let g:nerdtree_tabs_focus_on_files = 1
let g:nerdtree_tabs_open_on_new_tab = 1
nnoremap <silent> <Leader>w= :wincmd =<CR>
nnoremap <silent> <Leader>wr :NERDTreeToggle<CR>:wincmd r<CR>:NERDTreeToggle<CR>
nnoremap <silent> <Leader>wR :NERDTreeToggle<CR>:wincmd R<CR>:NERDTreeToggle<CR>
nnoremap <silent> <Leader>wK :NERDTreeToggle<CR>:wincmd K<CR>:NERDTreeToggle<CR>
nnoremap <silent> <Leader>wJ :NERDTreeToggle<CR>:wincmd J<CR>:NERDTreeToggle<CR>
nnoremap <silent> <Leader>wH :NERDTreeToggle<CR>:wincmd H<CR>:NERDTreeToggle<CR>
nnoremap <silent> <Leader>wL :NERDTreeToggle<CR>:wincmd L<CR>:NERDTreeToggle<CR>
