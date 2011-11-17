" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#paste
" Purpose: extract registers texts to paste

function! railmoon#oscan#extractor#paste#create()
    let new_extractor = copy(s:tag_scan_paste_extractor)
    let new_extractor.description = 'Select register to paste'
    let new_extractor.filetype = &filetype

    return new_extractor
endfunction

let s:tag_scan_paste_extractor = {}
function! s:tag_scan_paste_extractor.process(record)
    exec 'normal "'.a:record.data."p"
endfunction

function! s:tag_scan_paste_extractor.extract()
    let result = []

    redir => paste_string
    silent registers
    redir END

    let paste_list = split(paste_string, "\n")
    let pattern = '^"\(\S\)\s\s\s\(.*\)$'

    for line in paste_list
        if line !~ pattern
            continue
        endif

        let register_name = substitute(line, pattern, '\1', '')
        let register_value = eval('@'.register_name)

        let tags = railmoon#oscan#extractor#util#tags_from_line(register_value)

        let register_value_list = split( register_value, "\n" )
        let shortened_value_list = register_value_list
        if len( register_value_list ) > 5
            let shortened_value_list = register_value_list[0:2]
            call add(shortened_value_list, "... more ...")
            call extend(shortened_value_list, register_value_list[-2:-1])
        endif

        let additional_data = register_name
        let header = shortened_value_list

        if empty(header)
            continue
        endif

        call add(result, railmoon#oscan#record#create(header,
                    \ tags,
                    \ register_name,
                    \ register_name))
    endfor


    return result
endfunction

function! s:tag_scan_paste_extractor.colorize()
    syn match Identifier /\.\.\. more \.\.\./ 
endfunction

