" ========================================
" Linux specific General vim sanity improvements
" ========================================
"
" ========================================
" RSI Prevention - keyboard remaps
" ========================================
" Certain things we do every day as programmers stress
" out our hands. For example, typing underscores and
" dashes are very common, and in position that require
" a lot of hand movement. Vim to the rescue
"
" Now using the middle finger of either hand you can type
" underscores with Ctrl-k or Ctrl-d, and add Shift
" to type dashes
imap <silent> <C-k> _
imap <silent> <C-d> _
imap <silent> <C-K> -
imap <silent> <C-D> -

" Change inside various enclosures with Ctrl-" and Ctrl-'
" The f makes it find the enclosure so you don't have
" to be standing inside it
nnoremap <C-'> f'ci'
nnoremap <C-"> f"ci"
nnoremap <C-(> f(ci(
nnoremap <C-)> f)ci)
nnoremap <C-[> f[ci[
nnoremap <C-]> f]ci]

" ==== NERD tree
" Ctrl-Shift-N for nerd tree
nmap <C-N> :NERDTreeToggle<CR>

" move up/down quickly by using Ctrl-j, Ctrl-k
" which will move us around by functions
nnoremap <silent> <C-j> }
nnoremap <silent> <C-k> {
autocmd FileType ruby map <buffer> <C-j> ]m
autocmd FileType ruby map <buffer> <C-k> [m
autocmd FileType rspec map <buffer> <C-j> }
autocmd FileType rspec map <buffer> <C-k> {
autocmd FileType javascript map <buffer> <C-k> }
autocmd FileType javascript map <buffer> <C-j> {

" Command-/ to toggle comments
map <C-/> :TComment<CR>
imap <C-/> <Esc>:TComment<CR>i

" Use Alt- numbers to pick the tab you want
map <silent> <A-1> :tabn 1<cr>
map <silent> <A-2> :tabn 2<cr>
map <silent> <A-3> :tabn 3<cr>
map <silent> <A-4> :tabn 4<cr>
map <silent> <A-5> :tabn 5<cr>
map <silent> <A-6> :tabn 6<cr>
map <silent> <A-7> :tabn 7<cr>
map <silent> <A-8> :tabn 8<cr>
map <silent> <A-9> :tabn 9<cr>

" Create window splits easier. The default
" way is Ctrl-w,v and Ctrl-w,s. I remap
" this to vv and ss
nnoremap <silent> vv <C-w>v
nnoremap <silent> ss <C-w>s

" Resize windows with arrow keys
nnoremap <C-Up> <C-w>+
nnoremap <C-Down> <C-w>-
nnoremap <C-Left> <C-w><
nnoremap <C-Right>  <C-w>>

" ============================
" Tabularize - alignment
" ============================
" Hit Ctrl-Shift-A then type a character you want to align by
nmap <C-A> :Tabularize /
vmap <C-A> :Tabularize /

" Source current file Ctrl-% (good for vim development)
map <C-%> :so %<CR>
