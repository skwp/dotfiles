" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Home: www.railmoon.com
" Module: railmoon#widget#window
" Purpose: util functions for work with widget windows id
"

" -
" [ public library function ]
" Name: railmoon#widget#window#find_on_tab
" Purpose: determine window number on given tab with pointed id
" [ parameters ]
" tabpage_number        number of tabpage
" variable_name         name of window id variable
" id                    window id to search
" -
function! railmoon#widget#window#find_on_tab(tabpage_number, variable_name, id)
    let windows_count = tabpagewinnr(a:tabpage_number, '$')
    let window_number = 1

    while window_number <= windows_count
        let window_id = gettabwinvar(a:tabpage_number, window_number, a:variable_name)

        if a:id == window_id
            return window_number
        endif

        let window_number += 1

    endwhile
        
    return 0
endfunction

" -
" [ public library function ]
" Name: railmoon#widget#window#find
" Purpose: determine tabpage number and window number as list of two elements with pointed id
" [ parameters ]
" id                widget id to search
" -
function! railmoon#widget#window#find(id)
    let tabpage_count = tabpagenr('$')
    let tabpage_number = 1
    while tabpage_number <= tabpage_count
        let window_number = railmoon#widget#window#find_on_tab(tabpage_number, 'widget_id', a:id)
        if window_number
            return [ tabpage_number, window_number ]
        endif
        let tabpage_number += 1
    endwhile

    throw 'window with "widget_id" = '.a:id.' not found'
    return [0, 0]
endfunction

" -
" [ public library function ]
" Name: railmoon#widget#window#visible
" Purpose: determine visible or not widget window with pointed id
" [ parameters ]
" id                widget id to select
" -
function! railmoon#widget#window#visible(id)
    if exists('w:widget_id') && w:widget_id == a:id
        return 1
    endif

    let window_number = railmoon#widget#window#find_on_tab(tabpagenr(), 'widget_id', a:id)

    return window_number > 0
endfunction

" -
" [ public library function ]
" Name: railmoon#widget#window#select
" Purpose: make window with given widget id active
" [ parameters ]
" id                widget id to select
" -
function! railmoon#widget#window#select(id)
    call railmoon#trace#push('window#select')
    call railmoon#trace#debug('id = '.a:id)
    try

    if exists('w:widget_id') && w:widget_id == a:id
        return 1
    endif

    let tabpage_and_window_number = railmoon#widget#window#find(a:id)

    if tabpage_and_window_number[0] == 0
        return 0 
    endif

    call s:select_window(tabpage_and_window_number[0], tabpage_and_window_number[1])
    return 1

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction


" -
" [ public library function ]
" Name: railmoon#widget#window#save_selected
" Purpose: save current tabpage number, window mark id, position, mode
" -
function! railmoon#widget#window#save_selected()
    call railmoon#trace#push('window#save_selected')
    try

    if ! exists('w:railmoon_window_mark_id')
        let w:railmoon_window_mark_id = railmoon#id#acquire('railmoon_window_mark_id')
    endif
    return [tabpagenr(), w:railmoon_window_mark_id, getpos('.'), mode()]

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

" -
" [ public library function ]
" Name: railmoon#widget#window#load_selected
" Purpose: select tabpage number, window number, position, mode
" [ parameters ]
" selection         list with four elements: tabpage number, window mark id,
"                   position, mode
" -
function! railmoon#widget#window#load_selected(selection)
    call railmoon#trace#push('window#load_selected')
    try

    exec a:selection[0].'tabnext'
    let window_number =
        \ railmoon#widget#window#find_on_tab(a:selection[0],
        \                                'railmoon_window_mark_id', 
        \                                a:selection[1])

    exec window_number.'wincmd w'

    if a:selection[3] == 'n'
        stopinsert
    elseif a:selection[3] == 'i'
        startinsert
    endif
    call setpos('.', a:selection[2])

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

" -
" [ internal usage ]
" Purpose: open tabpage number and select window number
" -
function! s:select_window(tabpage_number, window_number)
    exec a:tabpage_number . 'tabnext'
    exec a:window_number.'wincmd w'
endfunction

