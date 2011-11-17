" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#marks
" Purpose: extract marks to select

function! railmoon#oscan#extractor#marks#create()
    let new_extractor = copy(s:tag_scan_marks_extractor)
    let new_extractor.description = 'Select mark to jump'
    let new_extractor.filetype = &filetype

    return new_extractor
endfunction

let s:tag_scan_marks_extractor = {}
function! s:tag_scan_marks_extractor.process(record)
    exec "normal \'".a:record.data
endfunction

function! s:tag_scan_marks_extractor.extract()
    let result = []

    redir => marks_string
    silent marks
    redir END

    let marks_list = split(marks_string, "\n")
    let pattern = '\s*\(\S\+\)\s*\(\d\+\)\s*\(\d\+\)\s*\(.*\)$'

    for mark_value in marks_list
        if mark_value !~ pattern
            continue
        endif

        let mark_symbol = substitute(mark_value, pattern, '\1', '')
        let mark_line = substitute(mark_value, pattern, '\2', '')
        let mark_col = substitute(mark_value, pattern, '\3', '')
        let mark_file_or_line = substitute(mark_value, pattern, '\4', '')

        let tags = []

        let file_name = fnamemodify(mark_file_or_line, ':p')

        let is_file = filereadable(file_name)

        if is_file
            let header_line = '<# '.file_name.' #>'
            let tags = railmoon#oscan#extractor#util#tags_from_file_name(file_name)
        else
            let header_line = mark_file_or_line
            let tags = split(mark_file_or_line, '\W')
            call filter(tags, 'v:val != ""')
            call add(tags, 'buffer')
        endif

        if mark_symbol =~ '[QWERTYUIOPASDFGHJKLZXCVBNM1234567890]'
            call add(tags, 'global')
        endif

        if mark_symbol =~ '[QWERTYUIOPASDFGHJKLZXCVBNM]'
            call add(tags, 'user')
        endif

        let header_line = printf("%5s %5s ", mark_line, mark_col).header_line

        let header = [ header_line ]
        call add(result, railmoon#oscan#record#create( header,
                    \ tags,
                    \ mark_symbol,
                    \ mark_symbol))
    endfor


    return result
endfunction

function! s:tag_scan_marks_extractor.colorize()
    syn match Comment /.*/ contained contains=Identifier
    syn region Identifier matchgroup=Ignore start='<#' end='#>' contained

    syn match TODO /\|/ nextgroup=Keyword
    syn match Keyword /\d\+\s/ nextgroup=Statement contained skipwhite
    syn match Statement /\d\+/ nextgroup=Comment contained skipwhite
endfunction

