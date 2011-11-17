" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#ctags#cpp
" Purpose: extract ctags cpp record from buffer


function! railmoon#oscan#extractor#ctags#cpp#kinds()
    return "cdefgmnpstuvx"
endfunction

function! railmoon#oscan#extractor#ctags#cpp#colorize()
    syntax keyword Type variable inner field enumeration function method public private protected global
    syntax keyword Keyword constructor destructor
    syntax keyword Identifier decl def
endfunction

function! railmoon#oscan#extractor#ctags#cpp#record( tag_item )
    let tag_list = []
    let header = ""
    let line_number = a:tag_item.cmd

    let kind = a:tag_item.kind
    let namespace = has_key(a:tag_item, 'namespace') ? a:tag_item.namespace : ''

    let is_object = 0
    let object_name = ''

    for name in ( [ has_key(a:tag_item, 'class') ? a:tag_item.class : ''
                \,  has_key(a:tag_item, 'struct') ? a:tag_item.struct : ''
                \,  has_key(a:tag_item, 'enum') ? a:tag_item.enum : ''
                \,  has_key(a:tag_item, 'union') ? a:tag_item.union : '' ] )
        if ! empty(name)
            let object_name = name
            let is_object = 1
            break
        endif
    endfor

    let tagname = split(a:tag_item.name, '::')[ -1]

    let is_constructor = 0
    let is_destructor = 0

    if is_object
        let last_part_of_object_name = split(object_name, '::')[ -1]
        let is_constructor = tagname == last_part_of_object_name
        let is_destructor = tagname == '~'.last_part_of_object_name
    endif


    if kind == 'f' || kind == 'p'
        if is_object
            if is_constructor
                let header .= 'constructor '
                call add(tag_list, 'constructor')
            elseif is_destructor
                let header .= 'destructor '
                call add(tag_list, 'destructor')
            else
                let header .= 'method '
                call add(tag_list, 'method')
            endif
        else
            let header .= "function "
            call add(tag_list, "function")
        endif

        if kind == 'p'
            let header .= 'decl. '
            call add(tag_list, "decl")
        else 
            let header .= 'def. '
            call add(tag_list, "def")
        endif
    elseif kind == 'c'
        let header .= "class "
        call add(tag_list, "class")
        call add(tag_list, "object")
    elseif kind == 'u'
        let header .= "union "
        call add(tag_list, "union")
        call add(tag_list, "object")
    elseif kind == 's'
        let header .= "struct "
        call add(tag_list, "struct")
        call add(tag_list, "object")
    elseif kind == 'g'
        let header .= "enum "
        call add(tag_list, "enum")
    elseif kind == 'd'
        let header .= "#define "
        call add(tag_list, "define")
    elseif kind == 'm'
        let header .= "field "
        call add(tag_list, "field")
    elseif kind == 'n'
        let header .= "namespace "
        call add(tag_list, "namespace")
    elseif kind == 't'
        let header .= "typedef "
        call add(tag_list, "typedef")
    elseif kind == 'v'
        let header .= "global variable "
        call extend(tag_list, ["variable", "global"])
    elseif kind == 'e'
        let header .= "enumeration "
        call add(tag_list, "enumeration")
    endif

    call add(tag_list, tagname)
    if is_object
        call extend(tag_list, split(object_name, '::'))
    endif

    if ! empty(namespace)
        call extend(tag_list, split(namespace, '::'))
    endif

    if is_object
        let header .= object_name.'::'
    endif

    if ! empty(namespace)
        let header .= namespace.'::'
    endif

    let header .= tagname

    if kind =~ '[fp]' && has_key(a:tag_item, 'signature')
        let header .= a:tag_item.signature
    endif

    let access = has_key(a:tag_item, 'access') ? a:tag_item.access : ''

    if ! empty(access)
        if kind =~ '[csug]'
            call add(tag_list, 'inner')
            let header = 'inner '.header
        endif

        let header = access.' '.header
        call add(tag_list, access)
    endif

    let file_name = has_key(a:tag_item, 'filename') ? a:tag_item.filename : ''

    return railmoon#oscan#record#create([header], tag_list, a:tag_item, fnamemodify(file_name, ':t'))
endfunction



