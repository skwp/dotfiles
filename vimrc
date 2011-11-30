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
set ignorecase  "ignore case when searching

set nowrap      "dont wrap lines
set linebreak   "wrap lines at convenient points

" swapfiles are lame. we have git
set noswapfile  
set nobackup
set nowb

" Better omnicomplete options (use Ctrl-P, Ctrl-N or Tab)
if v:version >= 700
  set omnifunc=syntaxcomplete#Complete " override built-in C omnicomplete with C++ OmniCppComplete plugin
  let OmniCpp_GlobalScopeSearch   = 1
  let OmniCpp_DisplayMode         = 1
  let OmniCpp_ShowScopeInAbbr     = 0 "do not show namespace in pop-up
  let OmniCpp_ShowPrototypeInAbbr = 1 "show prototype in pop-up
  let OmniCpp_ShowAccess          = 1 "show access in pop-up
  let OmniCpp_SelectFirstItem     = 1 "select first item in pop-up
  set completeopt=menuone,menu,longest
endif

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

    " colorscheme railscasts 
    colorscheme solarized
    set guitablabel=%M%t
    set lines=60
    set columns=190

    set guifont=Monaco:h17
    set guifont=Inconsolata:h20 " if available, this one is nicer
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
nnoremap <silent> <C-\> :call FindInNERDTree()<CR>:set winfixwidth<CR>

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

"open buf explorer with B
map B <Leader>bv
let g:bufExplorerShowRelativePath=1  " Show relative paths.
let g:bufExplorerDefaultHelp=0

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
imap <silent> <C-;> _

" hit \t to run current test
nmap <silent> <Leader>t :RunRubyFocusedContext<CR>

" set up automatic ctags
let Tlist_Ctags_Cmd='/opt/local/bin/ctags'
source ~/.vim/plugin/autotag.vim

" Run the current file in a ConqueTerm, great for ruby tests
let g:ConqueTerm_InsertOnEnter = 0
let g:ConqueTerm_CWInsert = 1
let g:ConqueTerm_Color = 2

" Open up a variety of commands in the ConqueTerm
nmap <silent> <Leader>r :call RunRubyCurrentFileConque()<CR>
nmap <silent> <Leader>S :call RunRspecCurrentFileConque()<CR>
nmap <silent> <Leader>R :call RunRakeConque()<CR>
nmap <silent> <Leader>c :execute 'ConqueTermSplit script/console --irb=pry'<CR>
nmap <silent> <Leader>i :execute 'ConqueTermSplit pry'<CR>
nmap <silent> <Leader>b :execute 'ConqueTermSplit /bin/bash --login'<CR>

function RunRubyCurrentFileConque()
  execute "ConqueTermSplit ruby" bufname('%')
endfunction

function RunRspecCurrentFileConque()
  execute "ConqueTermSplit rspec" bufname('%') " --color --format doc"
endfunction

function RunRakeConque()
  execute "ConqueTermSplit rake"
endfunction

let g:ConqueTerm_SendVisKey = '<Leader>e'

" prevent auto insert mode, which is helpful when using conque
" term for running tests
autocmd WinEnter * stopinsert

" Disable the scrollbars (NERDTree)
set guioptions-=r
set guioptions-=L

" Disable the macvim toolbar
set guioptions-=T

" Set up nicer coloring
hi LineNr  guifg=#505050   guibg=#101010
hi Normal  guifg=White     guibg=#101010
hi StatusLine guibg=#111111 guifg=#313131
hi Search guibg=#333333 guifg=#E05133
hi StatusLineNC guibg=#111111 guifg=#313131 
hi VertSplit guibg=#101010 guifg=#313131
hi treeDir guifg=#5285b4
hi Directory guifg=#5285b4
hi NonText guifg=#101010 "hide the blank line ~ marks
hi rubyClass guifg=lightgreen gui=bold

" this affects LustyJuggler's 'currently selected' color
" designed for use with solarized colorscheme
hi Question guifg=yellow

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

" Use EasyMotion by double tapping comma
nmap <silent> ,, \\w

" User LustyJuggler buffer switcher by hitting S
" and then using the homerow keys to select the file
" double tap the home row key to go to the file or hit
" once to just select it in the juggler
nmap <silent> S \lj
let g:LustyJugglerSuppressRubyWarning = 1
let g:LustyJugglerAltTabMode = 1

" Show me all my marks (using showmarks plugin) using \m
nnoremap <silent> <Leader>m :PreviewMarks<CR>

" copy current filename into system clipboard - mnemonic: (c)urrent(f)ilename
" this is helpful to paste someone the path you're looking at
nnoremap <silent> cf :let @* = expand("%:p")<CR>

" For fugitive.git, dp means :diffput. Define dg to mean :diffget
nnoremap <silent> dg :diffget<CR>

" alias W to write the file instead of :w
nnoremap W :w<CR>
