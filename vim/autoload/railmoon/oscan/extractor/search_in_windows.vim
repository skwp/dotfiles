" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#search_in_windows
" Purpose: extract strings with search pattern from all windows

function! railmoon#oscan#extractor#search_in_windows#create()
    let new_extractor = copy(s:tag_scan_search_in_windows_extractor)

    let new_extractor.pattern = @/
    let new_extractor.buffer_number = bufnr('%')
    let new_extractor.filetype = &filetype
    let new_extractor.description = 'Search "'.new_extractor.pattern.'" in all opened windows'
    let new_extractor.not_implemented = 1

    return new_extractor
endfunction

let s:tag_scan_search_in_windows_extractor = {}
function! s:tag_scan_search_in_windows_extractor.process(record)
endfunction

function! s:tag_scan_search_in_windows_extractor.tags_by_line(line_number, line) " line
    "return railmoon#oscan#extractor#util#tags_from_searched_line(a:line_number, a:line)
endfunction

function! s:tag_scan_search_in_windows_extractor.header_by_line(line_number, line)
    "let line = substitute(a:line, '^\s*', '', 'g')
    "return [ line ]
endfunction

function! s:tag_scan_search_in_windows_extractor.search_in_buffer(tabpage_number, window_number)
endfunction

function! s:tag_scan_search_in_windows_extractor.extract()
endfunction

function! s:tag_scan_search_in_windows_extractor.colorize()
endfunction

