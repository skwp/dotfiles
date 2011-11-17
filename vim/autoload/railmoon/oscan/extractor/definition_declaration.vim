" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#definition_declaration
" Purpose: extract ctags record from buffer

function! railmoon#oscan#extractor#definition_declaration#create()
    let new_extractor = copy(s:tag_scan_definition_declaration_extractor)

    let new_extractor.file_name = expand("%:p")
    let new_extractor.buffer_number = bufnr('%')
    let new_extractor.file_extension = expand("%:e")
    let new_extractor.filetype = &filetype
    let new_extractor.description = 'Go to possible definition/declaration for current function'

    return new_extractor
endfunction


let s:tag_scan_definition_declaration_extractor = {}
function! s:tag_scan_definition_declaration_extractor.process(record)
    call railmoon#oscan#extractor#ctags#process(a:record.data)
endfunction

function! s:get_nearest_ctags_tag()
    let filename = @%
    let linenumber = line('.')

    let self.language = railmoon#oscan#extractor#ctags#language_by_current_buffer()

    let ctags_tags = railmoon#ctags_util#taglist_for_file(filename, language, railmoon#oscan#extractor#ctags#kind_types_for_langauge(language), 'sikaS')

    let i = len(ctags_tags) - 1
    while i >= 0
        let tag_item = ctags_tags[i]

        if linenumber >= tag_item.cmd
            return tag_item
        endif
        let i -= 1
    endwhile

    return {}
endfunction

function! s:is_equal_tag_attribute(tag_left, tag_right, attribute)
    let left_has_attribute = has_key(a:tag_left, a:attribute)
    let right_has_attribute = has_key(a:tag_right, a:attribute)

    if left_has_attribute && right_has_attribute
        return a:tag_left[a:attribute] == a:tag_right[a:attribute]
    endif

    if ! left_has_attribute && ! right_has_attribute
        return 1
    endif

    return 0
endfunction

function! s:return_definitions(ctags_tag)
    let result = []
    let similar_tags = taglist('\<'.a:ctags_tag.name.'\>')

    for tag_item in similar_tags 
        if tag_item.kind == 'p'
            continue
        endif

        if s:is_equal_tag_attribute(a:ctags_tag, tag_item, 'class') &&
                    \ s:is_equal_tag_attribute(a:ctags_tag, tag_item, 'namespace')

            call add(result, tag_item)
        endif
    endfor

    return result
endfunction

function! s:return_declarations(ctags_tag)
    let result = []
    let similar_tags = taglist('\<'.a:ctags_tag.name.'\>')

    for tag_item in similar_tags 
        if tag_item.kind != 'p'
            continue
        endif

        if s:is_equal_tag_attribute(a:ctags_tag, tag_item, 'class') &&
                    \ s:is_equal_tag_attribute(a:ctags_tag, tag_item, 'namespace')

            call add(result, tag_item)
        endif
    endfor

    return result
endfunction

function! s:tag_scan_definition_declaration_extractor.extract()
    let result = []

    let extension = self.file_extension
    let language = railmoon#oscan#extractor#ctags#language_by_extension(extension)
    let self.language = language

    let nearest_tag = s:get_nearest_ctags_tag()
    let ctags_tags = nearest_tag.kind =~ 'p' ? s:return_definitions(nearest_tag) : s:return_declarations(nearest_tag)

    for item in ctags_tags
        let record = railmoon#oscan#extractor#ctags#record_for_language_tag(language, item)
        call add(result, record)
    endfor

    return result
endfunction

function! s:tag_scan_definition_declaration_extractor.colorize()
    let &filetype = self.filetype
    call railmoon#oscan#extractor#ctags#colorize_keywords(self.language)
endfunction
