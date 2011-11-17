" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#taglist_under_cursor
" Purpose: extract ctags records that fit word under curosr 

function! railmoon#oscan#extractor#taglist_under_cursor#create()
    let new_extractor = copy(s:tag_scan_taglist_under_cursor_extractor)

    let new_extractor.file_name = expand("%:p")
    let new_extractor.file_extension = expand("%:e")
    let new_extractor.filetype = &filetype
    let new_extractor.word_under_cursor = expand('<cword>')
    let new_extractor.description = 'Jump to tag "'.new_extractor.word_under_cursor.'" according to "'.&tags.'" tags dabase'

    return new_extractor
endfunction

let s:tag_scan_taglist_under_cursor_extractor = {}
function! s:tag_scan_taglist_under_cursor_extractor.process(record)
    exec 'tag '.self.word_under_cursor
    call railmoon#oscan#extractor#ctags#process(a:record.data)
endfunction

function! s:record_for_language_tag( language, ctag_item )
    return railmoon#oscan#extractor#ctags#language_function( a:language, 'record', a:ctag_item )
endfunction

function! s:tag_scan_taglist_under_cursor_extractor.extract()
    if empty(self.word_under_cursor)
        return []
    endif

    let result = []

    let self.language = railmoon#oscan#extractor#ctags#language_by_current_buffer()

    let ctags_tags = taglist('\<'.self.word_under_cursor.'\>')

    for item in ctags_tags
        let record = s:record_for_language_tag(self.language, item)
        let record.data = item
        call add(result, record)
    endfor

    return result
endfunction

function! s:tag_scan_taglist_under_cursor_extractor.colorize()
    let &filetype = self.filetype
    call railmoon#oscan#extractor#ctags#colorize_keywords(self.language)
endfunction

