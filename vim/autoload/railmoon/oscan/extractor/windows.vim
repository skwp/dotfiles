" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#windows
" Purpose: extract window names to select

function! railmoon#oscan#extractor#windows#create()
    let new_extractor = copy(s:tag_scan_windows_extractor)
    let new_extractor.description = 'Select window to be active'

    return new_extractor
endfunction

let s:tag_scan_windows_extractor = {}
function! s:tag_scan_windows_extractor.process(record)
    exec a:record.data[0].'tabnext'
    exec a:record.data[1].'wincmd w'
endfunction

function! s:tag_scan_windows_extractor.tags_by_name(buffer_name, buffer_number, tabpage_number, window_number)
    let tags = railmoon#oscan#extractor#util#tags_from_file_name(a:buffer_name)

    if index(tags, string(a:buffer_number)) == -1
        call add(tags, a:buffer_number)
    endif

    call add(tags, 'tabpage'.a:tabpage_number)
    call add(tags, 'window'.a:window_number)

    return tags
endfunction

function! s:tag_scan_windows_extractor.header_by_name(buffer_name, buffer_number)
    return [  a:buffer_name ]
endfunction

function! s:tag_scan_windows_extractor.extract()
    let lazyredraw_status = &lazyredraw

    set lazyredraw
    let result = []

    try

        for tabpage_number in range(1, tabpagenr('$'))
            exec (tabpage_number) . 'tabnext'
            
            for window_number in range(1, winnr('$'))

                let buffer_number = winbufnr(window_number)
                let buffer_name = bufname(buffer_number)
                exec window_number.'wincmd w'
                let line_number = line('.')

                call add(result, railmoon#oscan#record#create( self.header_by_name(buffer_name, buffer_number),
                            \ self.tags_by_name(buffer_name, buffer_number, tabpage_number, window_number),
                            \ [tabpage_number, window_number],
                            \ '[ '.tabpage_number.', '.window_number.' ] '.fnamemodify(buffer_name, ':p:t').' '.line_number))

            endfor 
        endfor

    catch /.*/
        echo v:exception
        echo v:throwpoint

    finally
        let &lazyredraw = lazyredraw_status
        return result
    endtry
endfunction

function! s:tag_scan_windows_extractor.colorize()
    syntax match Comment /|.\{-}|/
    syntax match Keyword /[\\/]/
    syntax match Number /[0-9]\+/
endfunction

