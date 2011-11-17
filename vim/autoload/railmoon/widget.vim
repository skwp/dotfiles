" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Module: railmoon#widget
" Purpose: common util function for widget functionality

let s:handle_autocommands = 1

function! railmoon#widget#stop_handle_autocommands()
    let s:handle_autocommands = 0
endfunction

function! railmoon#widget#start_handle_autocommands()
    let s:handle_autocommands = 1
endfunction

function! railmoon#widget#handle_autocommands()
    return s:handle_autocommands
endfunction


