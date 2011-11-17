" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#search_in_scope
" Purpose: extract strings that visible in current scope

function! railmoon#oscan#extractor#search_in_scope#create()
    let new_extractor =  railmoon#oscan#extractor#search#create()

    let new_extractor.first_line_to_search = searchpair('{', '', '}', 'bn')
    let new_extractor.last_line_to_search = searchpair('{', '', '}', 'n')
    let new_extractor.pattern = '.*'
    let new_extractor.remove_leader_space = 0
    let new_extractor.description = 'Search in current scope. '.new_extractor.first_line_to_search.':'.new_extractor.last_line_to_search

    return new_extractor
endfunction

