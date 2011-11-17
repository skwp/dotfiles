" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#buffers
" Purpose: extract buffer names to select

function! railmoon#oscan#extractor#buffers#create()
    let new_extractor = copy(s:tag_scan_buffers_extractor)
    let new_extractor.description = 'Select buffer to edit'

    return new_extractor
endfunction

let s:tag_scan_buffers_extractor = {}
function! s:tag_scan_buffers_extractor.process(record)
    if &modified
        let choice = inputlist( [ "Buffer is modified.", "1. Save current and continue" , "2. Break", "3. Open in new tab" ] )
        if 1 == choice
            update
        elseif 2 == choice
            return
        elseif 3 == choice
            tab new
        else 
            tab new
        endif
    endif

    exec 'buffer '.a:record.data
endfunction

function! s:tag_scan_buffers_extractor.tags_by_name(buffer_name, buffer_number)
    let tags = railmoon#oscan#extractor#util#tags_from_file_name(a:buffer_name)

    if index(tags, string(a:buffer_number)) == -1
        call add(tags, a:buffer_number)
    endif

    return tags
endfunction

function! s:tag_scan_buffers_extractor.header_by_name(buffer_name, buffer_number)
    return [  a:buffer_name ]
endfunction

function! s:tag_scan_buffers_extractor.extract()
    let result = []

    let buffers = railmoon#oscan#extractor#util#buffer_list()

    for buffer_info in buffers

        let buffer_number = buffer_info[0]
        let buffer_name = buffer_info[1]

        call add(result, railmoon#oscan#record#create( self.header_by_name(buffer_name, buffer_number),
                    \ self.tags_by_name(buffer_name, buffer_number),
                    \ buffer_number,
                    \ buffer_number))

    endfor


    return result
endfunction

function! s:tag_scan_buffers_extractor.colorize()
    syntax match FileName /.*\zs\/.*\ze/

    hi link FileName Identifier
endfunction

