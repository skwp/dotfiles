" Use tpope's pathogen plugin to manage all other plugins
call pathogen#infect()

"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

" Line numbers are good
set number

" I don't like code folding
set nofoldenable

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default

set nowrap      "dont wrap lines
set linebreak   "wrap lines at convenient points

" swapfiles are lame. we have git
set noswapfile  
set nobackup
set nowb

" persistent undos - undo after you re-open the file
" but this gives warnings under command line vim
" use only in macvim
if has('gui_running')
  set undodir=~/.vim/backups
  set undofile
endif

" indent
set ai " autoindent
set si " smart indent
set smarttab

"statusline setup
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline=%#warningmsg#
set statusline+=%f
set statusline+=%{fugitive#statusline()}
set statusline+=%m      "modified flag

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*
set statusline+=%=      "left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%c:     "cursor column
set statusline+=%l/%L   "cursor line/total lines
"set statusline+=\ %P    "percent through file
set laststatus=2

"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"indent settings
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set autoindent

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

"make cmdline tab completion similar to bash
set wildmode=list:longest   
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing

"display tabs and trailing spaces
set list
set listchars=tab:\ \ ,extends:>,precedes:<

set formatoptions-=o "dont continue comments when pushing o/O

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"load ftplugins and indent files
filetype plugin on
filetype indent on

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

"hide buffers when not displayed
set hidden

" Make it beautiful - colors and fonts
if has("gui_running")
		"tell the term has 256 colors
		set t_Co=256

    " http://ethanschoonover.com/solarized/vim-colors-solarized
    colorscheme solarized
    set background=dark

    set guitablabel=%M%t
    set lines=60
    set columns=190

    set guifont=Inconsolata:h20,Monaco:h17
else
		"dont load csapprox if we no gui support - silences an annoying warning
    let g:CSApprox_loaded = 1
endif

"make Y consistent with C and D
nnoremap Y y$

"mark syntax errors with :signs
let g:syntastic_enable_signs=1
"automatically jump to the error when saving the file
let g:syntastic_auto_jump=1 
"show the error list automatically
let g:syntastic_auto_loc_list=1
"don't care about warnings
let g:syntastic_quiet_warnings=1

"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

" Open the project tree and expose current file in the nerdtree with Ctrl-\
" the winfixwidth call ensures that nerdtree will not resize
" if we create or remove other windows
let g:NERDTreeWinSize = 30 
nnoremap <silent> <C-\> :NERDTreeFind<CR>

" move up/down quickly by using Ctrl-j, Ctrl-k
" which will move us around by functions
nnoremap <silent> <C-j> }
nnoremap <silent> <C-k> {

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

"open the taglist (method browser) using T
nnoremap <silent> T :TlistToggle<CR>

" taglist defaults 
let Tlist_Auto_Highlight_Tag=0
let Tlist_Auto_Open=0
let Tlist_Compact_Format = 1
let Tlist_Exist_OnlyWindow = 1 
let Tlist_WinWidth = 40 
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Show_Menu = 1
let Tlist_Use_Right_Window = 1
let Tlist_Use_Horiz_Window = 0
let Tlist_Close_On_Select = 1
let Tlist_Show_One_File = 1
let Tlist_Enable_Fold_Column = 0
let Tlist_Display_Prototype = 0
let Tlist_Use_SingleClick = 1

" automaticaly reload files changed outside of vim
set autoread

" save up to 100 marks and f1 means global marks (capital letters) are enabled
set viminfo='100,f1

" hit F to find the definition of the current class
" this uses ctags. the standard way to get this is Ctrl-]
nnoremap <silent> F <C-]>

"toggle between last two buffers with Z (normally ctrl-shift-6)
nnoremap <silent> Z <C-^>

"git grep the current word using K (mnemonic Kurrent)
nnoremap <silent> K :GitGrep <cword><CR>

"open up a git grep line, with a quote started for the search
"mnemonic: the letter O looks like a magnifying glass or goggles (search)
nnoremap O :GitGrep "

" create <%= foo %> erb tags using Ctrl-k in edit mode
imap <silent> <C-K> <%=   %><Esc>3hi

" create <%= foo %> erb tags using Ctrl-j in edit mode
imap <silent> <C-J> <%  %><Esc>2hi


" hit \t to run current test
nmap <silent> <Leader>t :RunRubyFocusedContext<CR>

" set up automatic ctags
let Tlist_Ctags_Cmd='/opt/local/bin/ctags'

" Run the current file in a ConqueTerm, great for ruby tests
let g:ConqueTerm_InsertOnEnter = 0
let g:ConqueTerm_CWInsert = 1
let g:ConqueTerm_Color = 2

" Open up a variety of commands in the ConqueTerm
nmap <silent> <Leader>cc :execute 'ConqueTermSplit script/console --irb=pry'<CR>
nmap <silent> <Leader>pp :execute 'ConqueTermSplit pry'<CR>
nmap <silent> <Leader>bb :execute 'ConqueTermSplit /bin/bash --login'<CR>

let g:ConqueTerm_SendVisKey = '<Leader>e'

" prevent auto insert mode, which is helpful when using conque
" term for running tests
autocmd WinEnter * stopinsert

" Disable the scrollbars (NERDTree)
set guioptions-=r
set guioptions-=L

" Disable the macvim toolbar
set guioptions-=T


" show this many lines around what i'm editing
set so=8

" aliases (C)opy (c)ommand - which allows us to execute
" the line we're looking at (it does so by yy-copy, colon
" to get to the command mode, C-f to get to history editing
" p to paste it, C-c to return to command mode, and CR to execute
nmap <silent> Cc yy:<C-f>p<C-c><CR>

" Find references to the currently opened partial (file)
" by pressing P in command mode 
function GitGrepCurrentPartial() 
  " :call GitGrep(substitute(substitute(expand('%<'),'.*\/_','','g'),'.html','','g'))
  :call GitGrep(substitute(substitute(substitute(expand('%<'),'.*\/','','g'), '$_','','g'),'.html','','g'))
endfunction
command! GitGrepCurrentPartial call GitGrepCurrentPartial()
nnoremap <silent> P :GitGrepCurrentPartial<CR>


" Remember cursor position and etc when you leave windows
" au BufWinLeave * silent! mkview  "make vim save view (state) (folds, cursor, etc)
" au BufWinEnter * silent! loadview "make vim load view (state) (folds, cursorrsor, etc)

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif


" Make nerdtree look nice
let NERDTreeMinimalUI = 1 
let NERDTreeDirArrows = 1

" Don't have to use Shift to get into command mode, just hit semicolon
nnoremap ; :

"Clear current search highlight by double tapping //
nmap <silent> // :nohlsearch<CR>




" copy current filename into system clipboard - mnemonic: (c)urrent(f)ilename
" this is helpful to paste someone the path you're looking at
nnoremap <silent> cf :let @* = expand("%:p")<CR>


" General vim sanity improvements
" ========================================
" alias yw to yank the entire word even if the
" cursor is inside the word
nnoremap yw yaw
" alias W to write the file instead of :w
nnoremap W :w<CR> 


" RSI Prevention - keyboard remaps
" ========================================
" in code, undescores and dashes are very commmon, but 
" the key is really far away. remap Apple-k to give us
" underscores and Apple-Shift-K to give dashes. 
" home row for the win!
imap <silent> <D-k> _
imap <silent> <D-K> -


" fugitive.git
" ========================================
" For fugitive.git, dp means :diffput. Define dg to mean :diffget
nnoremap <silent> dg :diffget<CR>


" tComment
" ========================================
" extensions for tComment plugin. Normally
" tComment maps 'gcc' to comment current line
" this adds 'gcp' comment current paragraph (block)
" using tComment's built in <c-_>p mapping
nmap <silent> gcp <c-_>p


" LustyJuggler 
" ========================================
" better triggers for buffer switching
" B to use the juggler, S to search the buffers
nmap <silent> B \lj
nmap <silent> S \lb

let g:LustyJugglerSuppressRubyWarning = 1
let g:LustyJugglerAltTabMode = 1
" Colors to make LustyJuggler more usable
" the Question color in LustyJuggler is mapped to
" the currently selected buffer.
hi clear Question
hi! Question guifg=yellow


" EasyMotion
" ========================================
" Use EasyMotion by double tapping comma
nmap <silent> ,, \\w
" Use EasyMotion backwards by z,,
nmap <silent> z,, \\b
" Make EasyMotion more yellow, less red
hi clear EasyMotionTarget
hi! EasyMotionTarget guifg=yellow

" This remaps easymotion to show us only the left
" hand home row keys as navigation options which 
" may mean more typing to get to a particular spot
" but it'll all be isolated to one area of the keyboard
call EasyMotion#InitOptions({
\   'leader_key'      : '<Leader><Leader>'
\ , 'keys'            : 'fjdkslewio'
\ , 'do_shade'        : 1
\ , 'do_mapping'      : 1
\ , 'grouping'        : 1
\
\ , 'hl_group_target' : 'Question'
\ , 'hl_group_shade'  : 'EasyMotionShade'
\ })

" vim-ruby-conque
" ========================================
let g:ruby_conque_rspec_command='spec'


" ShowMarks 
" ========================================
" Tell showmarks to not include the various brace marks (),{}, etc
let g:showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY"

" Tell showmarks to stop using the '>' indicator for marks
let g:showmarks_textlower="\t>" 
let g:showmarks_textupper="\t>"

" neocomplcache
" A beter autocomplete system!
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_min_syntax_length = 5
