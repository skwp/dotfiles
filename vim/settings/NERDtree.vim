" Make nerdtree look nice
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeQuitOnOpen = 1
let g:NERDTreeWinSize = 35
let NERDTreeIgnore = ['node_modules$']

nnoremap <silent> <Leader>d :let NERDTreeQuitOnOpen = 1<bar>NERDTreeToggle<CR>
nnoremap <silent> <Leader>D :let NERDTreeQuitOnOpen = 0<bar>NERDTreeToggle<CR>

" Open the project tree and expose current file in the nerdtree with Ctrl-\
nnoremap <silent> <C-\> :NERDTreeFind<CR>:vertical res 30<CR>
