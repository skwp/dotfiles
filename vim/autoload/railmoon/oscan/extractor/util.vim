" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#util
" Purpose: common extration and tag generation functions

function! railmoon#oscan#extractor#util#tags_from_file_name(file_name)
    let tags = []
    let name_tags = split(a:file_name, '\W')

    for l:tag in name_tags
        if empty(l:tag)
            continue
        endif

        if index(tags, string(l:tag)) != -1
            continue
        endif

        call add(tags, l:tag)
    endfor
    
    return tags
endfunction

function! railmoon#oscan#extractor#util#tags_from_line(line)
    let tags = split(a:line, '\W')
    call filter(tags, 'v:val != ""')

    if a:line =~ '='
        call extend(tags, ['equal', '='])
    endif

    if a:line =~ '"' || a:line =~ "'"
        call extend(tags, ['quotes', '"'])
    endif

    if a:line =~ '\.'
        call extend(tags, ['dot', '.'])
    endif

    if a:line =~ '[+-/\*]'
        call add(tags, 'sign')
    endif

    if a:line =~ '&&' || a:line =~ '||' || a:line =~ '==' || a:line =~ '!=' " TODO in one expression
        call add(tags, 'logic')
    endif

    return tags
endfunction

function! railmoon#oscan#extractor#util#tags_from_searched_line(line_number, line)
    let tags = railmoon#oscan#extractor#util#tags_from_line( a:line )
    call add(tags, a:line_number)

    return tags
endfunction

function! railmoon#oscan#extractor#util#buffer_list()
    let result = []

    for buffer_number in range(1, bufnr('$'))
        if !buflisted(buffer_number)
            continue
        endif

        call add(result, [buffer_number, fnamemodify(bufname(buffer_number), ':p')] )
    endfor

    return result
endfunction

