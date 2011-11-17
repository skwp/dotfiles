" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Module: railmoon#trace
" Purpose: help write debug information and call stack


function! railmoon#trace#start_debug(file_name)
    let s:is_debug_on = 1
    let s:debug = 1
    let s:log_file_name = a:file_name
    call delete(s:log_file_name)
    exec 'redir! > '.s:log_file_name
    echo 'start_debug'
    exec 'redir END'
endfunction

function! railmoon#trace#push(function_name)
    if s:is_debug_on
        call add(s:stack, a:function_name)
    endif
endfunction

function! railmoon#trace#pop()
    if s:is_debug_on
        let s:stack = s:stack[ : -2]
    endif
endfunction

function! railmoon#trace#debug(message)
    if s:debug
        call s:write(a:message)
    endif
endfunction

function! s:write(message)
    exec 'redir >> '.s:log_file_name
    silent echo '[ '.join(s:stack, ' >> ').'] '.a:message
    exec 'redir END'
endfunction

let s:is_debug_on = 0
let s:debug = 0
let s:stack = []

