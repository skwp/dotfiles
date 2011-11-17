" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Module: railmoon#widget#selection_window
" Purpose: provide window with ability to select elements

" -
" [ internal usage ]
" Name: callback_object
" Purpose: handler for base back calls
" -
let s:callback_object = {}



"
" elements for selection windows are dictionaries that have
" .data as list [] of text 
" .header optional value that will be right aligned at left side of list

" -
" [ public library function ]
" Name: railmoon#widget#selection_window#create
" Purpose: create "selection window" widget
" [ parameters ]
" name              name of new vim window that will represent widget
" titlename         name that will on title bar
" callback_object   call back object with following methods
"                       on_select(selected_line_text)
"                       on_close
"                       on_close_with_tab_page
" model             model representation with following methods
"                       get_item(element)
"                       get_item_count()
" -
function! railmoon#widget#selection_window#create(name, titlename, selection_group, model, callback_object)
    let new_object = railmoon#widget#base#create(a:name, a:titlename, s:selection_window, s:callback_object, a:callback_object)

    call railmoon#trace#debug('create selection_window:'.a:name)
    call railmoon#trace#debug(string(new_object))
    
    let new_object.selected_item_number = 1
    let new_object.selection_group = a:selection_group
    let new_object.model = a:model
    let new_object.yoffset = 0

    let new_object.item_positions = []

"    call new_object.draw_selection()

    call s:auto_command_setup()
    call s:key_mappings_setup()

    return new_object
endfunction

" -
" [ internal usage ]
" Name: auto_command_setup
" Purpose: setup handlers for window triggers
" -
function! s:auto_command_setup()
    autocmd CursorMoved <buffer> call s:on_cursor_moved()
endfunction

function! s:callback_object.on_setup()
    call s:key_mappings_setup()
endfunction

" -
" [ internal usage ]
" Name: key_mappings_setup
" Purpose: setup key handlers for "selection window"
" -
function! s:key_mappings_setup()
    nnoremap <buffer> <CR> :call <SID>on_select()<CR>
    nnoremap <buffer> <2-LeftMouse> :call <SID>on_select()<CR>
endfunction

" -
" [ internal usage ]
" Name: on_select
" Purpose: handle item select command
" -
function! s:on_select()
    let selected_item = w:widget.selected_item()
    call railmoon#widget#base#call_back(w:widget, 'on_select', '"'.escape(string(selected_item),"\"'").'"')
endfunction

" -
" [ internal usage ]
" Name: on_cursor_moved
" Purpose: handle normal mode curor movement
" -
function! s:on_cursor_moved()
    let line_number = line('.')
    call w:widget.select_line(line_number)
endfunction

" -
" [ internal usage ]
" Name: selection_window
" Purpose: widget object "selection window"
" -
let s:selection_window = {}

" -
" [ internal usage ]
" Name: highlight_line
" Purpose: highlight line in selection window
" [ parameters ]
" line_number       number of line to highlight
" group             highlight group to use as highlight
" -
function! s:highlight_line(start, end, group)
    let start = '"\%'.(a:start + 1).'l"'
    let end = '"\%'.(a:end + 1).'l"'
    let id = w:widget_id
    let syn_command = 'syn region selection_window_selected_line'.id.' start='.start.' end = '.end.' contains=Search'
    let hi_link_command = 'hi link selection_window_selected_line'.id.' '.a:group
    exec syn_command
    exec hi_link_command
endfunction

" -
" [ internal usage ]
" Name: clear_highlight_line
" Purpose: remove highlight line in selection window
" -
function! s:clear_highlight_line()
    let id = w:widget_id
    try
        exec 'syntax clear selection_window_selected_line'.id
    catch /.*/
    endtry
endfunction

" -
" [ object method ]
" Object: selection_window
" Name: draw
" Purpose: append all lines to buffer while remove old ones
" -
function! s:selection_window.draw()
    call railmoon#trace#push('selection_window.draw')
    try

    let selected = railmoon#widget#window#save_selected()
    let is_selected = railmoon#widget#window#select(self.id)

    if ! is_selected
        throw 'widget:selection_window:draw:window_not_found'
    endif

    setlocal modifiable

    0,$delete _


    let y = 0
    let i = 0
    let item_count = self.model.get_item_count()
    let item_size = len(self.model.get_item(0).data)
    let header_max_lenght = 0

    let self.item_positions = []

    let items_to_draw = []

    " gathrer visual items on window
    " determine max header length
    "
    while y <= ( winheight('%') - item_size ) && ( i < item_count )
        let item =  self.model.get_item(i)

        let item_header_len = len(item.header)

        if item_header_len > header_max_lenght
            let header_max_lenght = item_header_len
        endif 

        call add(items_to_draw, item)
        let item_size = len(item.data)

        call add( self.item_positions, [ y, y + item_size ] )

        let y += item_size
        let i += 1
    endwhile

    let is_no_headers = header_max_lenght == 0

    " highlight headers if any 
    "

    let window_id = w:widget_id
    try
        exec 'syntax clear selection_window_lines_header'.window_id
    catch /.*/
    endtry

    if ! is_no_headers
        exec 'syntax match selection_window_lines_header'.window_id.' "^[^|]\+|"'
    endif 

    try 
        exec 'hi link selection_window_lines_header'.window_id.' String'
    catch /.*/
    endtry

    let lines = []
    " build lines to append to buffer
    "
    for item in items_to_draw
        let item_header = item.header
        let is_header_present = len(item_header) > 0

        if is_header_present
            call add(lines, printf(' %-'.header_max_lenght.'s | ', item_header).item.data[0])
        elseif is_no_headers
            call add(lines, ' '.item.data[0])
        else 
            call add(lines, printf(' %'.header_max_lenght.'s   ', item_header).item.data[0])
        endif

        for line in item.data[1:]
            if is_header_present
                call add(lines, printf(' %-'.header_max_lenght.'s | ', '').line)
            elseif is_no_headers
                call add(lines, ' '.line)
            else
                call add(lines, printf(' %'.header_max_lenght.'s   ', '').line)
            endif
        endfor
    endfor 

    let win_width = winwidth('%')

    let wide_lines = []
    for line in lines 
        let diff = win_width - len(line) 

        let new_line = line
        if diff > 0
            let new_line = line . printf('%'.diff.'s', ' ')
        endif

        call add(wide_lines, new_line)
    endfor

    call setline(1, wide_lines)
    call self.draw_selection()

    setlocal nomodifiable

    call railmoon#widget#window#load_selected(selected)

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

" -
" [ object method ]
" Object: selection_window
" Name: draw_selection
" Purpose: show selection in selection window
" -
function! s:selection_window.draw_selection()
    call railmoon#trace#push('selection_window.draw_selection')
    call railmoon#trace#debug('id = '.self.id)
    try

    let selected = railmoon#widget#window#save_selected()

    call self.select()

    if len(self.item_positions) >  0
        let start_line_number_in_window = self.item_positions[ self.selected_item_number - 1 ][0]
        let end_line_number_in_window = self.item_positions[ self.selected_item_number - 1 ][1]
        exec start_line_number_in_window

        call s:clear_highlight_line()
        call s:highlight_line(start_line_number_in_window, end_line_number_in_window, self.selection_group)
    endif

    call railmoon#widget#window#load_selected(selected)

    finally
        call railmoon#trace#pop()
    endtry
endfunction


" -
" [ object method ]
" Object: selection_window
" Name: scrool_to
" Purpose: scrool window to show given line as first line
" [ parameters ]
"   line_number         line to show first in window
" -
function! s:selection_window.scrool_to(line_number)
    let self.yoffset = a:line_number

    call self.draw()
endfunction


" -
" [ object method ]
" Object: selection_window
" Name: selection_down
" Purpose: select next item
" [ parameters ]
" cycle         cycle or not movement
" -
function! s:selection_window.selection_down(cycle)
    let last_item_number_on_window = len(self.item_positions)

    if self.selected_item_number >= last_item_number_on_window
        if ! a:cycle
            return
        else
            let self.selected_item_number = 1
        endif
    else
        let self.selected_item_number += 1
    endif

    
    call self.draw_selection()
endfunction

" -
" [ object method ]
" Object: selection_window
" Name: selection_up
" Purpose: select previous item
" [ parameters ]
" cycle         cycle or not movement
" -
function! s:selection_window.selection_up(cycle)
    let last_item_number_on_window = len(self.item_positions)

    if self.selected_item_number <= 1
        if ! a:cycle
            return
        else
            let self.selected_item_number = last_item_number_on_window
        endif
    else
        let self.selected_item_number -= 1
    endif

    
    call self.draw_selection()
endfunction
 
" -
" [ object method ]
" Object: selection_window
" Name: select_line
" Purpose: select pointed line
" [ parameters ]
" line_number       number of line to select
" -
function! s:selection_window.select_line(line_number)
    let item_count = self.model.get_item_count()

    let i = 0
    for region in self.item_positions
        if a:line_number >= region[0] && a:line_number <= region[1]
            let self.selected_item_number = i + 1
            break
        endif

        let i+=1
    endfor 

    call self.draw_selection()
endfunction

" -
" [ object method ]
" Object: selection_window
" Name: select_item
" Purpose: select pointed item by number
" [ parameters ]
" item_number       number of item to select
" -
function! s:selection_window.select_item(item_number)
    let self.selected_item_number = a:item_number
    call self.draw_selection()
endfunction

" -
" [ object method ]
" Object: selection_window
" Name: selected_item
" Purpose: return selected item text
" -
function! s:selection_window.selected_item()
    let item = self.model.get_item(self.selected_item_number - 1)
    return item
endfunction

