let g:indexed_search_colors=0
" File:         IndexedSearch.vim
" Author:       Yakov Lerner <iler.ml@gmail.com>
" URL:          http://www.vim.org/scripts/script.php?script_id=1682
" Last change:  2006-11-21
"
" This script redefines 6 search commands (/,?,n,N,*,#). At each search,
" it shows at which match number you are, and the total number 
" of matches, like this: "At Nth match out of M". This is printed
" at the bottom line at every n,N,/,?,*,# search command, automatically.
"
" To try out the plugin, source it and play with N,n,*,#,/,? commands.
" At the bottom line, you'll see wha it shows. There are no new 
" commands and no new behavior to learn. Just additional info
" on the bottom line, whenever you perform search.
"
" Works on vim6 and vim7. On very large files, won't cause slowdown 
" because it checks the file size.
" Don't use if you're sensitive to one of its components :-)
"
" I am posting this plugin because I find it useful.
" -----------------------------------------------------
" Checking Where You Are with respect to Search Matches
" .....................................................
" You can press \\ or \/ (that's backslach then slash), 
" or :ShowSearchIndex to show at which match index you are,
" without moving cursor.
"
" If cursor is exactly on the match, the message is: 
"     At Nth match of M
" If cursor is between matches, following messages are displayed:
"     Betwen matches 189-190 of 300
"     Before first match, of 300
"     After last match, of 300
" ------------------------------------------------------
" To disable colors for messages, set 'let g:indexed_search_colors=0'.
" ------------------------------------------------------
" Performance. Plugin bypasses match counting when it would take
" too much time (too many matches, too large file). You can
" tune performance limits below, after comment "Performance tuning limits"
" ------------------------------------------------------
" In case of bugs and wishes, please email: iler.ml at gmail.com
" ------------------------------------------------------


" before 061119, it worked only vim7 not on vim6 (we use winrestview())
" after  061119, works only on vim6 (we avoid winrestview on vim6)


"if version < 700 | finish | endif " we need vim7 at least. Won't work for vim6

"if &cp | echo "warning: IndexedSearch.vim need nocp" | finish | endif " we need &nocp mode

if exists("g:indexed_search_plugin") | finish | endif
let g:indexed_search_plugin = 1

if !exists('g:indexed_search_colors')
    let g:indexed_search_colors=1 " 1-use colors for messages, 0-no colors
endif

if !exists('g:indexed_search_shortmess')
    let g:indexed_search_shortmess=0 " 1-longer messages; 0(or undefined)-longer messages.
endif


" ------------------ "Performance tuning limits" -------------------
if !exists('g:search_index_max')
  let g:search_index_max=30000 " max filesize(in lines) up to what
                               " ShowCurrentSearchIndex() works
endif
if !exists("g:search_index_maxhit")
  let g:search_index_maxhit=1000
endif
" -------------- End of Performance tuning limits ------------------

let s:save_cpo = &cpo
set cpo&vim


command! ShowSearchIndex :call s:ShowCurrentSearchIndex(1,'')


" before 061114  we had op invocation inside the function but this
"                did not properly keep @/ and direction (func.return restores @/ and direction)
" after  061114  invoking op inside the function does not work because
"                @/ and direction is restored at return from function
"                We must have op invocation at the toplevel of mapping even though this
"                makes mappings longer.
nnoremap <silent>n :let v:errmsg=''<cr>:silent! norm! n<cr>:call <SID>ShowCurrentSearchIndex(0,'!')<cr>
nnoremap <silent>N :let v:errmsg=''<cr>:silent! norm! N<cr>:call <SID>ShowCurrentSearchIndex(0,'!')<cr>
nnoremap <silent>* :let v:errmsg=''<cr>:silent! norm! *<cr>:call <SID>ShowCurrentSearchIndex(0,'!')<cr>
nnoremap <silent># :let v:errmsg=''<cr>:silent! norm! #<cr>:call <SID>ShowCurrentSearchIndex(0,'!')<cr>


nnoremap <silent>\/        :call <SID>ShowCurrentSearchIndex(1,'')<cr>
nnoremap <silent>\\        :call <SID>ShowCurrentSearchIndex(1,'')<cr>
nnoremap <silent>g/        :call <SID>ShowCurrentSearchIndex(1,'')<cr>


" before 061120,  I had cmapping for <cr> which was very intrusive. Didn't work
"                 with supertab iInde<c-x><c-p>(resulted in something like recursive <c-r>=
" after  061120,  I remap [/?] instead of remapping <cr>. Works in vim6, too

nnoremap / :call <SID>DelaySearchIndex(0,'')<cr>/
nnoremap ? :call <SID>DelaySearchIndex(0,'')<cr>?


let s:ScheduledEcho = ''
let s:DelaySearchIndex = 0
let g:IndSearchUT = &ut


func! s:ScheduleEcho(msg,highlight)

    "if &ut > 50 | let g:IndSearchUT=&ut | let &ut=50 | endif
    "if &ut > 100 | let g:IndSearchUT=&ut | let &ut=100 | endif
    if &ut > 200 | let g:IndSearchUT=&ut | let &ut=200 | endif
    " 061116 &ut is sometimes not restored and drops permanently to 50. But how ?

    let s:ScheduledEcho      = a:msg
    let use_colors = !exists('g:indexed_search_colors') || g:indexed_search_colors
    let s:ScheduledHighlight = ( use_colors ? a:highlight : "None" )

    aug IndSearchEcho

    au CursorHold * 
      \ exe 'set ut='.g:IndSearchUT | 
      \ if s:DelaySearchIndex | call s:ShowCurrentSearchIndex(0,'') | 
      \    let s:ScheduledEcho = s:Msg | let s:ScheduledHighlight = s:Highlight |
      \    let s:DelaySearchIndex = 0 | endif |
      \ if s:ScheduledEcho != "" 
      \ | exe "echohl ".s:ScheduledHighlight | echo s:ScheduledEcho | echohl None
      \ | let s:ScheduledEcho='' | 
      \ endif | 
      \ aug IndSearchEcho | exe 'au!' | aug END | aug! IndSearchEcho
    " how about moving contents of this au into function

    aug END
endfun " s:ScheduleEcho


func! s:DelaySearchIndex(force,cmd)
    let s:DelaySearchIndex = 1
    call s:ScheduleEcho('','')
endfunc


func! s:ShowCurrentSearchIndex(force, cmd)
    " NB: function saves and restores @/ and direction
    " this used to cause me many troubles

    call s:CountCurrentSearchIndex(a:force, a:cmd) " -> s:Msg, s:Highlight

    if s:Msg != ""
        call s:ScheduleEcho(s:Msg, s:Highlight )
    endif
endfun


function! s:MilliSince( start )
    " usage: let s = reltime() | sleep 100m | let milli = MilliSince(s)
    let x = reltimestr( reltime( a:start ) )
    " there can be leading spaces in x
    let sec   = substitute(x, '^ *\([0-9]\+\)', '\1', '')
    let frac = substitute(x, '\.\([0-9]\+\)',  '\1', '') . "000"
    let milli = strpart( frac, 0, 3)
    return sec * 1000 + milli
endfun


func! s:CountCurrentSearchIndex(force, cmd)
" sets globals -> s:Msg , s:Highlight
    let s:Msg = '' | let s:Highlight = ''
    let builtin_errmsg = ""

    " echo "" | " make sure old msg is erased
    if a:cmd == '!'
        " if cmd is '!', we do not execute any command but report
        " last errmsg
        if v:errmsg != ""
            echohl Error
            echomsg v:errmsg
            echohl None
        endif
    elseif a:cmd != ''
        let v:errmsg = ""

        silent! exe "norm! ".a:cmd

        if v:errmsg != ""
            echohl Error
            echomsg v:errmsg
            echohl None
        endif
        
        if line('$') >= g:search_index_max
            " for large files, preserve original error messages and add nothing
            return ""
        endif
    else
    endif

    if !a:force && line('$') >= g:search_index_max
        let too_slow=1
        " when too_slow, we'll want to switch the work over to CursorHold
        return ""
    endif
    if @/ == '' | return "" | endif
    if version >= 700 
		let save = winsaveview()
    endif
    let line = line('.')
    let vcol = virtcol('.')
    norm gg0
    let num = 0    " total # of matches in the buffer
    let exact = -1
    let after = 0
    let too_slow = 0 " if too_slow, we'll want to switch the work over to CursorHold
    let s_opt = 'Wc'
    while search(@/, s_opt) && ( num <= g:search_index_maxhit  || a:force)
        let num = num + 1
        if line('.') == line && virtcol('.') == vcol
            let exact = num
        elseif line('.') < line || (line('.') == line && virtcol('.') < vcol)
            let after = num
        endif
        let s_opt = 'W'
    endwh
    if version >= 700
		call winrestview(save)
	else
		exe line
		exe "norm! ".vcol."|"
    endif
    if !a:force && num > g:search_index_maxhit
        if exact >= 0 
            let too_slow=1 "  if too_slow, we'll want to switch the work over to CursorHold
            let num=">".(num-1)
        else
            let s:Msg = ">".(num-1)." matches"
            if v:errmsg != ""
                let s:Msg = ""  " avoid overwriting builtin errmsg with our ">1000 matches"
            endif
            return ""
        endif
    endif

    let s:Highlight = "Directory"
    if num == "0"
        let s:Highlight = "Error"
        let prefix = "No matches "
    elseif exact == 1 && num==1
        " s:Highlight remains default
        "let prefix = "At single match"
        let prefix = "Single match"
    elseif exact == 1
        let s:Highlight = "Search"
        "let prefix = "At 1st  match, # 1 of " . num
        "let prefix = "First match, # 1 of " . num
        let prefix = "First of " . num . " matches "
    elseif exact == num
        let s:Highlight = "LineNr"
        "let prefix = "Last match, # ".num." of " . num
        "let prefix = "At last match, # ".num." of " . num
        let prefix = "Last of " . num . " matches "
    elseif exact >= 0
        "let prefix = "At # ".exact." match of " . num
        "let prefix = "Match # ".exact." of " . num
        "let prefix = "# ".exact." match of " . num
        if exists('g:indexed_search_shortmess') && g:indexed_search_shortmess
            let prefix = exact." of " . num . " matches "
        else
            let prefix = "Match ".exact." of " . num
        endif
    elseif after == 0
        let s:Highlight = "MoreMsg"
        let prefix = "Before first match, of ".num." matches "
        if num == 1
            let prefix = "Before single match"
        endif
    elseif after == num
        let s:Highlight = "WarningMsg"
        let prefix = "After last match of ".num." matches "
        if num == 1
            let prefix = "After single match"
        endif
    else
        let prefix = "Between matches ".after."-".(after+1)." of ".num
    endif
    let s:Msg = prefix . "  /".@/ . "/"
    return ""
endfunc


"           Messages Summary
"
" Short Message            Long Message
" -------------------------------------------
" %d of %d matches         Match %d of %d
" Last of %d matches       <-same
" First of %d matches      <-same
" No matchess              <-same
" -------------------------------------------

let &cpo = s:save_cpo

" Last changes
" 2006-10-20 added limitation by # of matches
" 061021 lerner fixed problem with cmap <enter> that screwed maps 
" 061021 colors added
" 061022 fixed g/ when too many matches
" 061106 got message to work with check for largefile right
" 061110 addition of DelayedEcho(ScheduledEcho) fixes and simplifies things
" 061110 mapping for nN*# greately simplifified by switching to ScheduledEcho
" 061110 fixed problem with i<c-o>/pat<cr> and c/PATTERN<CR> Markus Braun
" 061110 fixed bug in / and ?, Counting moved to Delayd
" 061110 fixed bug extra line+enter prompt in [/?] by addinf redraw
" 061110 fixed overwriting builtin errmsg with ">1000 matches"
" 061111 fixed bug with gg & 'set nosol' (gg->gg0)
" 061113 fixed mysterious eschewing of @/ wfte *,#
" 061113 fixed counting of match at the very beginning of file
" 061113 added msgs "Before single match", "After single match"
" 061113 fixed bug with &ut not always restored. This could happen if
"        ScheduleEcho() was called twice in a row.
" 061114 fixed problem with **#n. Direction of the last n is incorrect (must be backward
"              but was incorrectly forward)
" 061114 fixed disappearrance of "Hit BOTTOM" native msg when file<max and numhits>max
" 061116 changed hlgroup os "At last match" from DiffChange to LineNr. Looks more natural.
" 061120 shortened text messages.
" 061120 made to work on vim6
" 061120 bugfix for vim6 (virtcol() not col())
" 061120 another bug with virtcol() vs col()
" 061120 fixed [/?] on vim6 (vim6 doesn't have getcmdtype())
" 061121 fixed mapping in <cr> with supertab.vim. Switched to [/?] mapping, removed <cr> mapping.
"        also shortened code considerably, made vim6 and vim7 work same way, removed need
"        for getcmdtype().
" 061121 fixed handling of g:indexed_search_colors (Markus Braun)


" Wishlist
" -  using high-precision timer of vim7, count number of millisec
"    to run the counters, and base auto-disabling on time it takes.
"    very complex regexes can be terribly slow even of files like 'man bash'
"    which is mere 5k lines long. Also when there are >10k matches in the file
"    set limit to 200 millisec
" - implement CursorHold bg counting to which too_slow will resort
" - even on large files, we can show "At last match", "After last match"
" - define global vars for all highlights, with defaults
" hh
" hh
" hh
" hh
