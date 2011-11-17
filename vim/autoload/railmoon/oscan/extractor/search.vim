" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#search
" Purpose: extract strings with search pattern from current file

function! railmoon#oscan#extractor#search#create()
    let new_extractor = copy(s:tag_scan_search_extractor)

    let new_extractor.file_name = expand("%:p")
    let new_extractor.buffer_number = bufnr('%')
    let new_extractor.file_extension = expand("%:e")
    let new_extractor.line_number_width = len(line('$'))
    let new_extractor.first_line_to_search = 1
    let new_extractor.last_line_to_search = line('$')
    let new_extractor.pattern = @/
    let new_extractor.remove_leader_space = 1
    let new_extractor.filetype = &filetype
    let new_extractor.description = 'Search "'.new_extractor.pattern.'" in "'.new_extractor.file_name.'"'

    return new_extractor
endfunction

let s:tag_scan_search_extractor = {}
function! s:tag_scan_search_extractor.process(record)
    exec 'buffer '.self.buffer_number
    exec a:record.data
endfunction

function! s:tag_scan_search_extractor.tags_by_line(line_number, line) " line
    return railmoon#oscan#extractor#util#tags_from_searched_line(a:line_number, a:line)
endfunction

function! s:tag_scan_search_extractor.header_by_line(line_number, line)
    if self.remove_leader_space
        let line = substitute(a:line, '^\s*', '', 'g')
    else
        let line = a:line
    endif

    return [ line ]
endfunction

function! s:tag_scan_search_extractor.extract()
    let result = []

    let pos = getpos('.')
    
    call cursor(self.first_line_to_search, 1)

    let pattern = self.pattern
    let last_search_result = -1

    let option = 'Wc'

    while 1
        let search_result = search(pattern, option, self.last_line_to_search)

        if search_result == 0
            break
        endif

        if search_result != last_search_result
            let line = getline(search_result)

            let data = self.header_by_line(search_result, line)
            let tag_list = self.tags_by_line(search_result, line)

            call add(result, railmoon#oscan#record#create(data, tag_list, search_result, search_result))
        endif

        let last_search_result = search_result
        let option = 'W'
    endwhile

    call setpos('.', pos)

    return result
endfunction

function! s:tag_scan_search_extractor.colorize()
    let &filetype = self.filetype
endfunction

