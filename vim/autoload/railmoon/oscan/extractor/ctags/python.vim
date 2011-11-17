" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#ctags#py
" Purpose: extract ctags python record from buffer


function! railmoon#oscan#extractor#ctags#python#kinds()
    return "cfm"
endfunction

function! railmoon#oscan#extractor#ctags#python#colorize()
    syntax keyword Type class function method inner public private
    syntax keyword Keyword constructor method
endfunction

function! railmoon#oscan#extractor#ctags#python#record( tag_item )
    let tag_list = []
    let header = ""
    let line_number = a:tag_item.cmd

    let kind = a:tag_item.kind

    let is_object = 0
    let object_name = ''

    for name in ( [ has_key(a:tag_item, 'class') ? a:tag_item.class : '' ] )
        if ! empty(name)
            let object_name = name
            let is_object = 1
            break
        endif
    endfor

    let tagname = a:tag_item.name

    let is_constructor = 0

    if is_object
        let is_constructor = tagname == '__init__'
    endif

    if kind == 'm'
        if is_object
            if is_constructor
                let header .= 'constructor '
                call add(tag_list, 'constructor')
            else
                let header .= 'method '
                call add(tag_list, 'method')
            endif
        endif
    elseif kind == 'c'
        let header .= "class "
        call add(tag_list, "class")
        call add(tag_list, "object")
    elseif kind == 'm'
        let header .= "function "
        call add(tag_list, "function")
    endif

    call add(tag_list, tagname)
    if is_object
        call extend(tag_list, split(object_name, '::'))
    endif

    if is_object
        let header .= object_name.'.'
    endif

    let header .= tagname

    if kind == 'c' && ! empty(object_name)
        call add(tag_list, 'inner')
        let header = 'inner '.header
    endif

    let access = has_key(a:tag_item, 'access') ? a:tag_item.access : ''
    if ! empty(access)
        let header = access.' '.header
        call add(tag_list, access)
    endif

    let file_name = has_key(a:tag_item, 'filename') ? a:tag_item.filename : ''

    return railmoon#oscan#record#create([header], tag_list, a:tag_item, fnamemodify(file_name, ':t'))
endfunction



