" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#changes
" Purpose: extract recently changed lines to jump to

function! railmoon#oscan#extractor#changes#create()
    let new_extractor = copy(s:tag_scan_changes_extractor)
    let new_extractor.description = 'Select recently changed lines to jump to'
    let new_extractor.filetype = &filetype

    return new_extractor
endfunction

let s:tag_scan_changes_extractor = {}
function! s:tag_scan_changes_extractor.process(record)
    exec a:record.data
endfunction

function! s:tag_scan_changes_extractor.extract()
    let result = []

    redir => changes_string
    silent changes
    redir END

    let changes_list = split(changes_string, "\n")
    let pattern = '\s*\(\d\+\)\s*\(\d\+\)\s*\(\d\+\)\s*\(.*\)$'

    call reverse(changes_list)
    for change_el in changes_list
        if change_el !~ pattern
            continue
        endif

        let line_number = substitute(change_el, pattern, '\2', '')
        let line = substitute(change_el, pattern, '\4', '')

        let tags = railmoon#oscan#extractor#util#tags_from_line(line)

        let header = [ line ]
        call add(result, railmoon#oscan#record#create( header,
                    \ tags,
                    \ line_number,
                    \ line_number))
    endfor

    return result
endfunction

function! s:tag_scan_changes_extractor.colorize()
endfunction

