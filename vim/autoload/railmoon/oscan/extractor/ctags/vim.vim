" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#ctags#vim
" Purpose: extract ctags vim record from buffer


function! railmoon#oscan#extractor#ctags#vim#kinds()
    return "afk"
endfunction

function! railmoon#oscan#extractor#ctags#vim#colorize()
    syntax keyword Type function variable autogroup
endfunction

function! railmoon#oscan#extractor#ctags#vim#record( tag_item )
    let tag_list = []
    let header = ""
    let line_number = a:tag_item

    let kind = a:tag_item.kind

    call add(tag_list, a:tag_item.name)

    if kind == 'a'
        let header .= "autogroup "
        call add(tag_list, "autogroup")
    elseif kind == 'f'
        let header .= "function "
        call add(tag_list, "function")
    elseif kind == 'v'
        let header .= "variable "
        call add(tag_list, "variable")
    endif

    let header .= a:tag_item.name

    return railmoon#oscan#record#create( [ ' '.header ], tag_list, line_number)
endfunction



