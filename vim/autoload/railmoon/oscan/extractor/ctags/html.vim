" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#ctags#py
" Purpose: extract ctags html record from buffer


function! railmoon#oscan#extractor#ctags#html#kinds()
    return "af"
endfunction

function! railmoon#oscan#extractor#ctags#html#colorize()
    syntax keyword Type anchor function
endfunction

function! railmoon#oscan#extractor#ctags#html#record( tag_item )
    let tag_list = []
    let header = ""

    let kind = a:tag_item.kind

    let tagname = a:tag_item.name
    "let tagname = substitute( tagname, "'\\(.*\\)'", "\1", "g" )
 
    if kind =~ 'a'
        let header .= 'anchor '
        call add(tag_list, 'anchor')
    elseif kind == 'f'
        let header .= "function "
        call add(tag_list, "function")
    endif

    call add(tag_list, tagname)

    let header .= tagname

    let file_name = has_key(a:tag_item, 'filename') ? a:tag_item.filename : ''

    return railmoon#oscan#record#create([header], tag_list, a:tag_item, fnamemodify(file_name, ':t'))
endfunction

