" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#search_on_screen
" Purpose: extract strings that visible on window from current file

function! railmoon#oscan#extractor#search_on_screen#create()
    let new_extractor =  railmoon#oscan#extractor#search#create()

    let new_extractor.first_line_to_search = line('w0')
    let new_extractor.last_line_to_search = line('w$')
    let new_extractor.pattern = '.*'
    let new_extractor.remove_leader_space = 0
    let new_extractor.description = 'Search on current window visible range. From line '. new_extractor.first_line_to_search.' to line '.new_extractor.last_line_to_search

    return new_extractor
endfunction

