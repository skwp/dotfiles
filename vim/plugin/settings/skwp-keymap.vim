" ========================================
" General vim sanity improvements
" ========================================
"
" alias yw to yank the entire word 'yank inner word'
" even if the cursor is halfway inside the word
" FIXME: will not properly repeat when you use a dot (tie into repeat.vim)
nnoremap ,yw yiww

" ,ow = 'overwrite word', replace a word with what's in the yank buffer
" FIXME: will not properly repeat when you use a dot (tie into repeat.vim)
nnoremap ,ow viwp

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
" Don't have to use Shift to get into command mode, just hit semicolon
nnoremap ; :

"Go to last edit location with ,.
nnoremap ,. '.

" ================== rails.vim
"
" Open corresponding unittest (or spec), alias for :AV in rails.vim 
nmap ,ru :AV<CR>

" ==== NERD tree
" ,m is less stressful on the fingers than ,n
nmap ,m :NERDTreeToggle<CR>

" ,q to toggle quickfix window (where you have stuff like GitGrep)
" ,oq to open it back up (rare)
nmap <silent> ,q :cclose<CR>
nmap <silent> ,oq :copen<CR>

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

" ==============================
" Window/Tab/Split Manipulation
" ==============================
" Move between split windows by using the four directions H, L, I, N 
" (note that  I use I and N instead of J and K because  J already does 
" line joins and K is mapped to GitGrep the current word
nnoremap <silent> H <C-w>h
nnoremap <silent> L <C-w>l
nnoremap <silent> I <C-w>k
nnoremap <silent> M <C-w>j

" Move between tabs with Cmd-Shift-H and Cmd-Shift-L
map <silent> <D-H> :tabprevious<cr>
map <silent> <D-L> :tabnext<cr>

" Zoom in and out of current window with ,,
map <silent> ,, <C-w>o

" Use numbers to pick the tab you want (like iTerm)
map <silent> <D-1> :tabn 1<cr>
map <silent> <D-2> :tabn 2<cr>
map <silent> <D-3> :tabn 3<cr>
map <silent> <D-4> :tabn 4<cr>
map <silent> <D-5> :tabn 5<cr>
map <silent> <D-6> :tabn 6<cr>
map <silent> <D-7> :tabn 7<cr>
map <silent> <D-8> :tabn 8<cr>
map <silent> <D-9> :tabn 9<cr>
map <silent> <D-0> :tabn 0<cr>

" Create window splits easier. The default
" way is Ctrl-w,v and Ctrl-w,s. I remap
" this to vv and ss
nnoremap <silent> vv <C-w>v
nnoremap <silent> ss <C-w>s

" Use Q to kill a buffer
nnoremap <silent> Q :bw<CR>

" Remap \Q to close a window (leave buffer open in memory)
nnoremap <silent> <Leader>Q <C-w>c

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
nnoremap <silent> ,cf :let @* = expand("%:p")<CR>

"Clear current search highlight by double tapping //
nmap <silent> // :nohlsearch<CR>

" (c)opy (c)ommand - which allows us to execute
" the line we're looking at (it does so by yy-copy, colon
" to get to the command mode, C-f to get to history editing
" p to paste it, C-c to return to command mode, and CR to execute
nmap <silent> ,cc yy:<C-f>p<C-c><CR>

" Type ,hl to toggle highlighting on/off, and show current value.
noremap ,hl :set hlsearch! hlsearch?<CR>

" Apple-* Highlight all occurrences of current word (like '*' but without moving)
" http://vim.wikia.com/wiki/Highlight_all_search_pattern_matches
nnoremap <D-*> :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>

" These are very similar keys. Typing 'a will jump to the line in the current
" file marked with ma. However, `a will jump to the line and column marked
" with ma.  It’s more useful in any case I can imagine, but it’s located way
" off in the corner of the keyboard. The best way to handle this is just to
" swap them: http://items.sjbach.com/319/configuring-vim-right
nnoremap ' `
nnoremap ` '

" Tabularization. Hit Ctrl-a then type a character you want to align by
if exists(":Tabularize")
  nmap <C-a> :Tabularize /
  vmap <C-a> :Tabularize /
endif

" ===
" SplitJoin plugin
nmap sj :SplitjoinSplit<cr>
nmap sk :SplitjoinJoin<cr>

" ============================
" VimBookmarking
" ============================
"
" Set anonymous bookmarks
nmap ,bb :ToggleBookmark<cr>
nmap ,bn :NextBookmark<cr>
nmap ,bp :PreviousBookmark<cr>
nmap ,bc :ClearBookmarks<cr>
"
" ============================
" Abbreviations to use...
" ============================
" snippets that are expanded with space
abbr pry! require 'pry'; binding.pry 

" If you use a fast_spec directory, Rfastspec can help you find
" one of your fast specs
autocmd User BufEnterRails Rnavcommand fastspec fast_spec/ -glob=**/** -suffix=_spec.rb -default=model()

