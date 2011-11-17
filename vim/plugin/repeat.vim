" repeat.vim - Let the repeat command repeat plugin maps
" Maintainer:   Tim Pope
" Version:      1.0

" Installation:
" Place in either ~/.vim/plugin/repeat.vim (to load at start up) or
" ~/.vim/autoload/repeat.vim (to load automatically as needed).
"
" Developers:
" Basic usage is as follows:
"
"   silent! call repeat#set("\<Plug>MappingToRepeatCommand",3)
"
" The first argument is the mapping that will be invoked when the |.| key is
" pressed.  Typically, it will be the same as the mapping the user invoked.
" This sequence will be stuffed into the input queue literally.  Thus you must
" encode special keys by prefixing them with a backslash inside double quotes.
"
" The second argument is the default count.  This is the number that will be
" prefixed to the mapping if no explicit numeric argument was given.  The
" value of the v:count variable is usually correct and it will be used if the
" second parameter is omitted.  If your mapping doesn't accept a numeric
" argument and you never want to receive one, pass a value of -1.
"
" Make sure to call the repeat#set function _after_ making changes to the
" file.

if exists("g:loaded_repeat") || &cp || v:version < 700
    finish
endif
let g:loaded_repeat = 1

let g:repeat_tick = -1

function! repeat#set(sequence,...)
    silent exe "norm! \"=''\<CR>p"
    let g:repeat_sequence = a:sequence
    let g:repeat_count = a:0 ? a:1 : v:count
    let g:repeat_tick = b:changedtick
endfunction

function! s:repeat(count)
    if g:repeat_tick == b:changedtick
        let c = g:repeat_count
        let s = g:repeat_sequence
        let cnt = c == -1 ? "" : (a:count ? a:count : (c ? c : ''))
        call feedkeys(cnt . s)
    else
        call feedkeys((a:count ? a:count : '') . '.', 'n')
    endif
endfunction

function! s:wrap(command,count)
    let preserve = (g:repeat_tick == b:changedtick)
    exe 'norm! '.(a:count ? a:count : '').a:command
    if preserve
        let g:repeat_tick = b:changedtick
    endif
endfunction

nnoremap <silent> .     :<C-U>call <SID>repeat(v:count)<CR>
nnoremap <silent> u     :<C-U>call <SID>wrap('u',v:count)<CR>
nnoremap <silent> U     :<C-U>call <SID>wrap('U',v:count)<CR>
nnoremap <silent> <C-R> :<C-U>call <SID>wrap("\<Lt>C-R>",v:count)<CR>

augroup repeatPlugin
    autocmd!
    autocmd BufLeave,BufWritePre,BufReadPre * let g:repeat_tick = (g:repeat_tick == b:changedtick || g:repeat_tick == 0) ? 0 : -1
    autocmd BufEnter,BufWritePost * if g:repeat_tick == 0|let g:repeat_tick = b:changedtick|endif
augroup END

" vim:set ft=vim et sw=4 sts=4:
