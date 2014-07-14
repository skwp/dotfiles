" ==== NERD tree
" Cmd-Shift-N for nerd tree
"nmap <D-N> :NERDTreeToggle<CR>
map <silent> <leader>tn :NERDTreeToggle<CR>
map <silent> <leader>tm :NERDTreeTabsToggle<CR>
" Open the project tree and expose current file in the nerdtree with Ctrl-\
nnoremap <silent> <C-\> :NERDTreeFind<CR>:vertical res 30<CR>

" Make nerdtree look nice
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let g:NERDTreeWinSize = 30
