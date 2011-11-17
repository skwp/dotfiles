" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#ctags
" Purpose: extract ctags record from tags

function! railmoon#oscan#extractor#taglist#create()
    let new_extractor = copy(s:tag_scan_taglist_extractor)

    let new_extractor.file_name = expand("%:p")
    let new_extractor.file_extension = expand("%:e")
    let new_extractor.filetype = &filetype
    let new_extractor.description = 'Move through all tags in "set tags=..." database'
    let new_extractor.not_implemented = 1

    return new_extractor
endfunction

let s:tag_scan_taglist_extractor = {}
function! s:tag_scan_taglist_extractor.process(record)
endfunction


function! s:tag_scan_taglist_extractor.extract()
    let result = []
    return result
endfunction

function! s:tag_scan_taglist_extractor.colorize()
    let &filetype = self.filetype
    call railmoon#oscan#extractor#ctags#colorize_keywords()
endfunction

