" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#multiline_search
" Purpose: extract strings ( and their neighbours)  with search pattern from current file

function! railmoon#oscan#extractor#multiline_search#create()
    let new_extractor = copy(s:tag_scan_multiline_search_extractor)

    let new_extractor.file_name = expand("%:p")
    let new_extractor.file_extension = expand("%:e")
    let new_extractor.first_line_to_search = 1
    let new_extractor.last_line_to_search = line('$')
    let new_extractor.pattern = @/
    let new_extractor.filetype = &filetype
    let new_extractor.description = 'Mutliline search "'.new_extractor.pattern.'" in "'.new_extractor.file_name.'"'

    return new_extractor
endfunction

let s:tag_scan_multiline_search_extractor = {}
function! s:tag_scan_multiline_search_extractor.process(record)
    exec a:record.data
endfunction

function! s:tag_scan_multiline_search_extractor.tags_by_line(line_number_start, data)
    let tags = []

    let i = 0
    for line in a:data
        call extend(tags, railmoon#oscan#extractor#util#tags_from_searched_line(a:line_number_start + i, line) )
        let i += 1
    endfor

    return tags
endfunction

function! s:tag_scan_multiline_search_extractor.extract()
    let result = []

    let pos = getpos('.')
    
    call cursor(self.first_line_to_search, 1)

    let pattern = self.pattern
    let last_search_result = -1

    let option = 'Wc'

    let match_pattern_line_numbers = [] 

    while 1
        let search_result = search(pattern, option, self.last_line_to_search)

        if search_result == 0
            break
        endif

        if search_result != last_search_result
            call add(match_pattern_line_numbers, search_result)
        endif

        let last_search_result = search_result
        let option = 'W'
    endwhile

    let match_cout = len(match_pattern_line_numbers)

    if match_cout == 0
        return result
    endif

    let min_block_size = 2
    let i = 0

    while i < match_cout

        let block_begin = match_pattern_line_numbers[i] - min_block_size
        let delta = 0
        if block_begin < self.first_line_to_search
            let delta = self.first_line_to_search - block_begin
            let block_begin = self.first_line_to_search
        endif 

        let block_end = match_pattern_line_numbers[i] + min_block_size + delta
        if block_end > self.last_line_to_search
            let block_end = self.last_line_to_search
        endif

        while i < match_cout 
            if match_pattern_line_numbers[i] - min_block_size > block_end
                let i -= 1
                break
            endif

            let block_end = match_pattern_line_numbers[i] + min_block_size
            
            let i += 1
        endwhile

        let data = getline(block_begin, block_end)
        let tag_list = self.tags_by_line(block_begin, data)

        call add(tag_list, block_begin)

        call add(result, railmoon#oscan#record#create(data, tag_list, block_begin, block_begin))

        let i +=1 
    endwhile


    call setpos('.', pos)

    return result
endfunction

function! s:tag_scan_multiline_search_extractor.colorize()
    let &filetype = self.filetype
    exec 'syn match Search "'.'\c'.self.pattern.'"'
"    exec 'syn match Identifier "[**].*"'
endfunction

