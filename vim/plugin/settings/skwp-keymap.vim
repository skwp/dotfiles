" ========================================
" General vim sanity improvements
" ========================================
"
" alias yw to yank the entire word even if the
" cursor is inside the word
nnoremap yw yaw
"make Y consistent with C and D
nnoremap Y y$

" ========================================
" RSI Prevention - keyboard remaps
" ========================================
" Certain things we do every day as programmers stress
" out our hands. For example, typing underscores and 
" dashes are very common, and in position that require
" a lot of hand movement. Vim to the rescue 
"
" Now using the middle finger of either hand you can type
" underscores with apple-k or apple-d, and add Shift
" to type dashes
imap <silent> <D-k> _
imap <silent> <D-d> _
imap <silent> <D-K> -
imap <silent> <D-D> -

" alias W to write the file instead of :w
nnoremap W :w<CR> 

" Don't have to use Shift to get into command mode, just hit semicolon
nnoremap ; :

" ================== rails.vim
"
" Open corresponding unit test/spec in a vertical split
nmap ,rt :AV<CR>

" ==== NERD tree
nmap ,n :NERDTreeToggle<CR>

" move up/down quickly by using Ctrl-j, Ctrl-k
" which will move us around by functions
nnoremap <silent> <C-j> }
nnoremap <silent> <C-k> {

" Open the project tree and expose current file in the nerdtree with Ctrl-\
nnoremap <silent> <C-\> :NERDTreeFind<CR>

" Command-/ to toggle comments
map <D-/> :TComment<CR>
imap <D-/> <Esc>:TComment<CR>i

"open up a git grep line, with a quote started for the search
nnoremap ,gg :GitGrep "
nnoremap ,gcp :GitGrepCurrentPartial<CR>

" hit ,f to find the definition of the current class
" this uses ctags. the standard way to get this is Ctrl-]
nnoremap <silent> ,f <C-]>

"toggle between last two buffers with Z (normally ctrl-shift-6)
nnoremap <silent> ,z <C-^>

"git grep the current word using K (mnemonic Kurrent)
nnoremap <silent> K :GitGrep <cword><CR>

" Move between split windows by using the four directions H, L, I, N 
" (note that  I use I and N instead of J and K because  J already does 
" line joins and K is mapped to GitGrep the current word
nnoremap <silent> H <C-w>h
nnoremap <silent> L <C-w>l
nnoremap <silent> I <C-w>k
nnoremap <silent> M <C-w>j

" Create window splits easier. The default
" way is Ctrl-w,v and Ctrl-w,s. I remap
" this to vv and ss
nnoremap <silent> vv <C-w>v
nnoremap <silent> ss <C-w>s

" Remap Q to close a window
nnoremap <silent> Q <C-w>c

" Use \Q to kill the buffer entirely
nnoremap <silent> <Leader>Q :bw<CR>

"open the taglist (method browser) using ,t 
nnoremap <silent> ,T :TlistToggle<CR>

" create <%= foo %> erb tags using Ctrl-k in edit mode
imap <silent> <C-K> <%=   %><Esc>3hi

" create <%= foo %> erb tags using Ctrl-j in edit mode
imap <silent> <C-J> <%  %><Esc>2hi

" ============================
" Shortcuts for everyday tasks
" ============================

" copy current filename into system clipboard - mnemonic: (c)urrent(f)ilename
" this is helpful to paste someone the path you're looking at
nnoremap <silent> cf :let @* = expand("%:p")<CR>

"Clear current search highlight by double tapping //
nmap <silent> // :nohlsearch<CR>

" (C)opy (c)ommand - which allows us to execute
" the line we're looking at (it does so by yy-copy, colon
" to get to the command mode, C-f to get to history editing
" p to paste it, C-c to return to command mode, and CR to execute
nmap <silent> Cc yy:<C-f>p<C-c><CR>

" Type ,hl to toggle highlighting on/off, and show current value.
noremap ,hl :set hlsearch! hlsearch?<CR>

" Apple-* Highlight all occurrences of current word (like '*' but without moving)
" http://vim.wikia.com/wiki/Highlight_all_search_pattern_matches
nnoremap <D-*> :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>

" After repeating a command, return the cursor to where it started
" http://vim.wikia.com/wiki/VimTip1142
nmap . .`[

" These are very similar keys. Typing 'a will jump to the line in the current
" file marked with ma. However, `a will jump to the line and column marked
" with ma.  It’s more useful in any case I can imagine, but it’s located way
" off in the corner of the keyboard. The best way to handle this is just to
" swap them: http://items.sjbach.com/319/configuring-vim-right
nnoremap ' `
nnoremap ` '

" Abbreviations to use...snippets that are expanded with space
abbr pry! require 'pry'; binding.pry 
