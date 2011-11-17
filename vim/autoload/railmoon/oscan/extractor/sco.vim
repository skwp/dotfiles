" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#sco
" Purpose: extract sco taged headers or sco folded result 

function! railmoon#oscan#extractor#sco#create()
    let new_extractor = copy(s:tag_scan_sco_extractor)


    let new_extractor.folded_result_start = searchpair('>>>', '', '<<<', 'bnW')
    let new_extractor.folded_result_end = searchpair('>>>', '', '<<<', 'nW')

    let new_extractor.buffer_number = bufnr('%')

    let new_extractor.is_extract_tag_headers = 0 == new_extractor.folded_result_start

    if new_extractor.is_extract_tag_headers
        let new_extractor.description = 'SourceCodeObedience. Select header to move to'
    else
        let new_extractor.description = 'SourceCodeObedience. Select result to move to'
    endif

    return new_extractor
endfunction

let s:tag_scan_sco_extractor = {}
function! s:tag_scan_sco_extractor.process(record)
    exec 'buffer '.self.buffer_number
    update
    e
    exec a:record.data

    if ! self.is_extract_tag_headers
        Enter
    endif
endfunction

function! s:tag_scan_sco_extractor.taged_headers_tags_by_line(line_number, line)
    return split(substitute(a:line, '^\s*tags:\(.*\)', '\1', ''), ',')
endfunction

function! s:tag_scan_sco_extractor.taged_headers_header_by_line(line_number, line)
    let line_with_header = getline(a:line_number - 1)
    if line_with_header =~ '^\s*header:'
        return [ substitute(line_with_header, '^\s*header:\(.*\)', '\1', '') ]
    endif

    return [ '[ '.substitute(a:line, '^\s*tags:\(.*\)', '\1', '').' ]' ]
endfunction

function! s:tag_scan_sco_extractor.extract_taged_headers()
    let result = []

    let pos = getpos('.')
    call cursor(1, 1)

    let pattern = '^\s*tags:'

    let option = 'Wc'

    while 1
        let search_result = search(pattern, option)

        if search_result == 0
            break
        endif

        let line = getline(search_result)

        let data = self.taged_headers_header_by_line(search_result, line)
        let tag_list = self.taged_headers_tags_by_line(search_result, line)

        call add(result, railmoon#oscan#record#create(data, tag_list, search_result, search_result))

        let option = 'W'
    endwhile

    call setpos('.', pos)

    return result
endfunction

let s:smart_mark_pattern_comment = '\s\+```\(.*[^>]\)>>.*$'
let s:smart_mark_pattern_without_comment = '@\s\+\(\S\+\)\s\+\(\d*\)\s\(.*\)'
let s:smart_mark_pattern = s:smart_mark_pattern_without_comment.s:smart_mark_pattern_comment

let s:sco_result_pattern = '^#\s\+\(\S\+\)\s\+\(\S\+\)\s\+\(\d\+\)\s\+\(.*\)$'

function! s:tag_scan_sco_extractor.extract_sco_results()
    let result = []

    let line_number = self.folded_result_start + 1

    while line_number < self.folded_result_end
        let line = getline(line_number)

        if line =~ s:sco_result_pattern
            let file_name = substitute(line, s:sco_result_pattern, '\1', '')
            let function_name = substitute(line, s:sco_result_pattern, '\2', '')
            let file_line_number = substitute(line, s:sco_result_pattern, '\3', '')
            let body = substitute(line, s:sco_result_pattern, '\4', '')

            let short_file_name = fnamemodify(file_name, ':t')

            let tag_list = []
            call extend(tag_list, railmoon#oscan#extractor#util#tags_from_line(body))
            call add(tag_list, function_name)
            call extend(tag_list, railmoon#oscan#extractor#util#tags_from_file_name(file_name))

            call add(result, railmoon#oscan#record#create([ body ], tag_list, line_number, short_file_name))
        endif

        let line_number += 1
    endwhile

    return result
endfunction

function! s:tag_scan_sco_extractor.extract()
    if self.is_extract_tag_headers
        return self.extract_taged_headers()
    endif


    return self.extract_sco_results()
endfunction

function! s:tag_scan_sco_extractor.colorize()
    if self.is_extract_tag_headers
        syntax match Comment '\[.*\]' contains=Keyword
        syntax keyword Keyword tag symbol file include text grep calling contained
    else
        setf cpp
    endif
endfunction

