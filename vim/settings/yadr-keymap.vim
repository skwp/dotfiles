" ========================================
" General vim sanity improvements
" ========================================
"
"
" alias yw to yank the entire word 'yank inner word'
" even if the cursor is halfway inside the word
" FIXME: will not properly repeat when you use a dot (tie into repeat.vim)
nnoremap ,yw yiww

" ,ow = 'overwrite word', replace a word with what's in the yank buffer
" FIXME: will not properly repeat when you use a dot (tie into repeat.vim)
nnoremap ,ow "_diwhp

"make Y consistent with C and D
nnoremap Y y$
function! YRRunAfterMaps()
  nnoremap Y   :<C-U>YRYankCount 'y$'<CR>
endfunction

" Make 0 go to the first character rather than the beginning
" of the line. When we're programming, we're almost always
" interested in working with text rather than empty space. If
" you want the traditional beginning of line, use ^
nnoremap 0 ^
nnoremap ^ 0

" ,# Surround a word with #{ruby interpolation}
map ,# ysiw#
vmap ,# c#{<C-R>"}<ESC>

" ," Surround a word with "quotes"
map ," ysiw"
vmap ," c"<C-R>""<ESC>

" ,' Surround a word with 'single quotes'
map ,' ysiw'
vmap ,' c'<C-R>"'<ESC>

" ,) or ,( Surround a word with (parens)
" The difference is in whether a space is put in
map ,( ysiw(
map ,) ysiw)
vmap ,( c( <C-R>" )<ESC>
vmap ,) c(<C-R>")<ESC>

" ,[ Surround a word with [brackets]
map ,] ysiw]
map ,[ ysiw[
vmap ,[ c[ <C-R>" ]<ESC>
vmap ,] c[<C-R>"]<ESC>

" ,{ Surround a word with {braces}
map ,} ysiw}
map ,{ ysiw{
vmap ,} c{ <C-R>" }<ESC>
vmap ,{ c{<C-R>"}<ESC>

map ,` ysiw`

" gary bernhardt's hashrocket
imap <c-l> <space>=><space>

"Go to last edit location with ,.
nnoremap ,. '.

"When typing a string, your quotes auto complete. Move past the quote
"while still in insert mode by hitting Ctrl-a. Example:
"
" type 'foo<c-a>
"
" the first quote will autoclose so you'll get 'foo' and hitting <c-a> will
" put the cursor right after the quote

" Emacs move in insert mode
inoremap <C-a> <C-O><S-i>
inoremap <C-e> <End>
inoremap <C-b> <LEFT>
inoremap <C-f> <RIGHT>
inoremap <C-h> <BACKSPACE>
inoremap <C-d> <DELETE>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <UP>
cnoremap <C-n> <DOWN>
cnoremap <C-b> <LEFT>
cnoremap <C-f> <RIGHT>
cnoremap <C-h> <BACKSPACE>
cnoremap <C-d> <DELETE>
"imap <C-a> <esc>wa
" ==== NERD tree
" Open the project tree and expose current file in the nerdtree with Ctrl-\
" " calls NERDTreeFind iff NERDTree is active, current window contains a modifiable file, and we're not in vimdiff
function! OpenNerdTree()
  if &modifiable && strlen(expand('%')) > 0 && !&diff
    NERDTreeFind
  else
    NERDTreeToggle
  endif
endfunction
nnoremap <silent> <C-\> :call OpenNerdTree()<CR>

" ,q to toggle quickfix window (where you have stuff like Ag)
" ,oq to open it back up (rare)
" instead, use ListToggle
nmap <silent> ,qc :cclose<CR>
nmap <silent> ,qo :copen<CR>

"Move back and forth through previous and next buffers
"with ,z and ,x
nnoremap <silent> ,z :bp<CR>
nnoremap <silent> ,x :bn<CR>

" ==============================
" Window/Tab/Split Manipulation
" ==============================
" Move between split windows by using the four directions H, L, K, J
" NOTE: This has moved to vim/settings/vim-tmux-navigator.vim.
" nnoremap <silent> <C-h> <C-w>h
" nnoremap <silent> <C-l> <C-w>l
" nnoremap <silent> <C-k> <C-w>k
" nnoremap <silent> <C-j> <C-w>j

" Make gf (go to file) create the file, if not existent
nnoremap <C-w>f :sp +e<cfile><CR>
nnoremap <C-w>gf :tabe<cfile><CR>

" Zoom in
map <silent> ,gz <C-w>o

" Create window splits easier. The default
" way is Ctrl-w,v and Ctrl-w,s. I remap
" this to vv and ss
nnoremap <silent> <Space>v <C-w>v
nnoremap <silent> <Space>s <C-w>s

nnoremap < <C-w>5<
nnoremap > <C-w>5>
nnoremap + <C-w>5+
nnoremap _ <C-w>5-

" create <%= foo %> erb tags using Ctrl-k in edit mode
"imap <silent> <C-K> <%=   %><Esc>3hi

" create <% foo %> erb tags using Ctrl-j in edit mode
"imap <silent> <C-J> <%  %><Esc>2hi

" ============================
" Shortcuts for everyday tasks
" ============================

" copy current filename into system clipboard - mnemonic: (c)urrent(f)ilename
" this is helpful to paste someone the path you're looking at
nnoremap <silent> ,cf :let @* = expand("%:~")<CR>
nnoremap <silent> ,cr :let @* = expand("%")<CR>
nnoremap <silent> ,cn :let @* = expand("%:t")<CR>

"Clear current search highlight by double tapping //
nmap <silent> // :nohlsearch<CR>

"(v)im (c)ommand - execute current line as a vim command
nmap <silent> ,vc yy:<C-f>p<C-c><CR>

"(v)im (r)eload
nmap <silent> ,vr :so %<CR>

" Type ,hl to toggle highlighting on/off, and show current value.
noremap ,hl :set hlsearch! hlsearch?<CR>

" These are very similar keys. Typing 'a will jump to the line in the current
" file marked with ma. However, `a will jump to the line and column marked
" with ma.  It’s more useful in any case I can imagine, but it’s located way
" off in the corner of the keyboard. The best way to handle this is just to
" swap them: http://items.sjbach.com/319/configuring-vim-right
nnoremap ' `
nnoremap ` '

" ============================
" Tabularize - alignment
" ============================
map <silent> <leader>aa :Tabularize /
map <silent> <leader>a= :Tabularize /=<CR>
map <silent> <leader>a: :Tabularize /:\zs<CR>

" ============================
" SplitJoin plugin
" ============================
" nmap sj :SplitjoinSplit<cr>
" nmap sk :SplitjoinJoin<cr>
nmap ss :SplitjoinSplit<cr>
nmap sj :SplitjoinJoin<cr>

" Get the current highlight group. Useful for then remapping the color
map ,hi :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">" . " FG:" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"fg#")<CR>

" ,hp = html preview
map <silent> ,hp :!open -a Safari %<CR><CR>

imap uu _
imap hh =>
imap kk ->
imap aa @

nnoremap <C-t>c :tabnew<CR>
nnoremap <silent> H :tabprevious<CR>
nnoremap <silent> L :tabnext<CR>

unmap H
unmap L
nnoremap ,ca :ChangeAroundSurrounding<CR>

let g:lasttab = 1
nnoremap <silent> T :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

nnoremap <silent> <leader>1 1gt
nnoremap <silent> <leader>2 2gt
nnoremap <silent> <leader>3 3gt
nnoremap <silent> <leader>4 4gt
nnoremap <silent> <leader>5 5gt
nnoremap <silent> <leader>6 6gt
nnoremap <silent> <leader>7 7gt
nnoremap <silent> <leader>8 8gt
nnoremap <silent> <leader>9 9gt
nnoremap <silent> <leader>9 9gt
nnoremap <silent> <leader>0 :tablast<CR>


nnoremap <silent> <Leader>w= :wincmd =<CR>
nnoremap <silent> <Leader>wr :NERDTreeToggle<CR>:wincmd r<CR>:NERDTreeToggle<CR>
nnoremap <silent> <Leader>wR :NERDTreeToggle<CR>:wincmd R<CR>:NERDTreeToggle<CR>
nnoremap <silent> <Leader>wK :NERDTreeToggle<CR>:wincmd K<CR>:NERDTreeToggle<CR>
nnoremap <silent> <Leader>wJ :NERDTreeToggle<CR>:wincmd J<CR>:NERDTreeToggle<CR>
nnoremap <silent> <Leader>wH :NERDTreeToggle<CR>:wincmd H<CR>:NERDTreeToggle<CR>
nnoremap <silent> <Leader>wL :NERDTreeToggle<CR>:wincmd L<CR>:NERDTreeToggle<CR>

"custom copy'n'paste
""copy the current visual selection to ~/.vbuf
vmap <silent> <leader>xy :w! ~/.vbuf<CR>
"copy the current line to the buffer file if no visual selection
nmap <silent> <leader>xy :.w! ~/.vbuf<CR>
""paste the contents of the buffer file
nmap <silent> <leader>xp :r ~/.vbuf<CR>

"Reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

"Improve up/down movement on wrapped lines
nnoremap j gj
nnoremap k gk

inoremap <expr> <c-j> pumvisible() ? "\<C-e>\<Down>" : "\<Down>"
inoremap <expr> <c-k> pumvisible() ? "\<C-e>\<Up>" : "\<Up>"


"to camel case
nmap <silent> <leader>> ciw<Esc>:let @"=substitute(strtrans(@"), '[A-Z]\C', '_\L&', 'g')<CR>"0p
"from camel case
nmap <silent> <leader>< ciw<Esc>:let @"=substitute(strtrans(@"), '_\([a-z]\)\C', '\U\1', 'g')<CR>"0p


"map for macro q
"<Space> has been mapped for Sneak/EasyMotion
nnoremap <Space><Space> @q

map <leader>ww :w<CR>
map <leader>xx :x<CR>
map <leader>qq :qa<CR>

"redraw
nmap <leader>rd :redraw!<CR>

nnoremap <F8> :set wrap! wrap?<CR>
imap <F8> <C-O><F8>
" Map Ctrl-x and Ctrl-z to navigate the quickfix error list (normally :cn and
" :cp)
nnoremap <silent> <C-x> :cn<CR>
nnoremap <silent> <C-z> :cp<CR>

