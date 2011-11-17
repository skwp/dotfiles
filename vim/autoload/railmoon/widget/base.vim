" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Module: railmoon#widget#base
" Purpose: base widget functionality and vim windows triggers handler

" -
" [ internal usage ]
" Purpose: collect widget that will be closed
" -
let s:widget_for_close = []

function! s:clear_widget_for_close()
    let s:widget_for_close = []
endfunction

function! s:widget_present(list, widget)
    for widget in a:list
        if widget.id == a:widget.id
            return 1
        endif
    endfor

    return 0
endfunction

function! s:add_widget_for_close(widget)
    if s:widget_present(s:widget_for_close, a:widget)
        return
    endif

    call add(s:widget_for_close, a:widget)
endfunction

function! s:remove_widget_from_delete(widget)
    if ! s:widget_present(s:widget_for_close, a:widget)
        return
    endif

    call filter(s:widget_for_close, 'v:val.id != '.a:widget.id)
endfunction

let s:buffer_name_prefix = 'rmwidget'
let s:in_create_widget_state = 0
" -
" [ public for extend library function ]
" Name: railmoon#widget#base#create
" Purpose: create base widget
" [ parameters ]
" name                  widget window name
" titlename             name that will on title bar
" child                 widget that inherit base
" child_callback_object call back object with following methods that child can
"                       react on
"                       on_close
"                       on_close_with_tab_page
"                       on_focus
"                       on_focus_lost
"                       on_setup
" callback_object       user defined call back object
" -
function! railmoon#widget#base#create(name, titlename, child, child_callback_object, callback_object)
    call s:clear_widget_for_close()

    let new_object = extend( deepcopy(s:base), deepcopy(a:child) )

    call railmoon#trace#debug('create base:'.a:name)
    call railmoon#trace#debug(string(new_object))
    
"    if bufexists(escaped_name)
"        throw 'widget:base:buffer_exists'
"    endif
    let new_object.id = railmoon#id#acquire('railmoon_widget_id')
    let new_object.name = a:name
    let new_object.titlename = a:titlename
    let new_object.child_callback_object = a:child_callback_object
    let new_object.callback_object = a:callback_object
    let new_object.is_closed = 0

    let buffer_name = s:buffer_name_prefix.new_object.id

    let s:in_create_widget_state = 1

    let buffer_number = bufnr( buffer_name )

    if  -1 == buffer_number
        exec 'silent edit '.buffer_name
    else
        exec 'silent buffer '.buffer_number
    endif

    exec 'setlocal statusline='.escape(new_object.name, ' ')
    setlocal noreadonly

    let w:widget_id = new_object.id
    let w:widget = new_object

    let b:widget_id = new_object.id
    let b:widget = new_object

    call s:buffer_auto_command_setup()
    call s:buffer_setup()

    let s:in_create_widget_state = 0
    return new_object
endfunction

" -
" [ internal usage ]
" Name: railmoon#widget#base#call_back
" Purpose: call back method for handlers
" -
function! railmoon#widget#base#call_back(widget, method_name, ... )
    let arguments = join(a:000, ';')
    call railmoon#trace#debug('call back for widget. name:'. a:widget.name. '; method:'.a:method_name.' ; arguments:'.arguments)

    let exec_line = 'call object.'.a:method_name.'('.arguments.')'
    for object in [ a:widget.child_callback_object, a:widget.callback_object ]
        if has_key(object, a:method_name)
            call railmoon#trace#debug(exec_line)
            exec exec_line
        endif
    endfor
endfunction

" -
" [ internal usage ]
" Name: buffer_option_setup
" Purpose: setup common local options for widget buffer
" -
function! s:buffer_option_setup()
    setlocal noswapfile
    setlocal nomodifiable
    setlocal bufhidden=delete
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal nonumber
    setlocal nowrap
    setlocal nocursorline
endfunction

function! s:redraw_widget()
    if has_key(b:widget, 'draw')
        call b:widget.draw()
    endif
endfunction


" -
" [ internal usage ]
" Name: buffer_setup
" Purpose: when buffer needs to be resetup. after reopen in widget window
" -
function! s:buffer_setup()
    call s:buffer_option_setup()
    let b:widget = w:widget
    let b:widget_id = w:widget_id

    call s:set_widget_title()

    if s:in_create_widget_state
        return
    endif

    call railmoon#widget#base#call_back(b:widget, 'on_setup')
    call s:redraw_widget()
endfunction

" -
" [ internal usage ]
" Name: buffer_auto_command_setup
" Purpose: setup common handlers for window triggers
" -
function! s:buffer_auto_command_setup()
    autocmd! * <buffer>
    autocmd BufWinLeave <buffer> call s:on_buffer_win_leave()
    autocmd WinEnter <buffer> call s:on_window_enter()
    autocmd WinLeave <buffer> call s:on_window_leave()
    autocmd TabLeave <buffer> call s:on_tab_leave()
endfunction

" -
" [ internal usage ]
" Name: auto_command_setup
" Purpose: setup handlers for any window or buffer to resolve conflicts
" -
function! s:auto_command_setup()
    augroup base_widget_autocommands
        autocmd!
        autocmd WinEnter * call s:on_any_window_enter()
        autocmd BufEnter * call s:on_any_buffer_enter()
        autocmd BufWinEnter * call s:on_any_buffer_window_enter()
"        autocmd BufWinLeave * call s:on_any_buffer_win_leave()
    augroup END
endfunction

function! s:widget_in_auto_command()
    let buffer_name = expand('<afile>')
    let widget = getbufvar(buffer_name, 'widget')

    if empty(widget)
        throw 'widget not found!!!! TODO'
    endif

    return widget
endfunction

function! s:on_any_buffer_window_enter()
    call railmoon#trace#push('on_any_buffer_window_enter')
    try

    let buffer_name = expand('<afile>')
    call railmoon#trace#debug('name: '.buffer_name)

    if empty(buffer_name) " TODO
        return
    endif

    if ! railmoon#widget#handle_autocommands()
        call railmoon#trace#debug('handle autocommands stoped')
        return
    endif


    if exists('w:widget_id') && !exists('b:widget_id')
        call railmoon#trace#debug('w:widget_id present but b:widget_id not')
        call s:remove_widget_from_delete(w:widget)
        let buffer_number = bufnr(s:buffer_name_prefix.w:widget_id)
        let buffer_change_cmd = 'buffer '.buffer_number
        call railmoon#trace#debug(buffer_change_cmd)
        exec buffer_change_cmd
        call s:buffer_setup()
        return
    endif

    if exists('b:widget_id') && !exists('w:widget_id')
        call railmoon#trace#debug('b:widget exists but w:widget not')
        close
        return
    endif

    catch /.*/
        echo v:exception
        call railmoon#trace#debug(v:exception)

    finally
        if exists('w:widget')
            call s:remove_widget_from_delete(w:widget)
        endif

        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction
" -
" [ internal usage ]
" Name: on_buffer_win_leave
" Purpose: handle widget close event
" -
function! s:on_buffer_win_leave()
    call railmoon#trace#push('on_buffer_win_leave')
    try

    let widget = s:widget_in_auto_command()

    call railmoon#trace#debug('widget for close set up')
    call s:add_widget_for_close(widget)
    if widget.is_closed
        call railmoon#trace#debug('already closed')
        return
    endif

    let buffer_name = expand('<afile>')
    " closed by close tab page 
    " TODO find out another cases 
    " when <afile> != %
    if buffer_name != bufname('%')
        let s:close_with_tab_page = 1 
        " TODO s:close_with_tab_page 
    else
        let s:close_with_tab_page = 0
    endif

    finally
        call s:close_ready_for_close_widgets()
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

function! railmoon#widget#base#gui_tab_label()
    if v:lnum == s:current_tab_page_number
        return s:current_widget_name
    endif

"    let old_line = s:old_gui_tab_label
"    let old_line = substitute(old_line, '%{\(.\{-}\)}', '\1', 'g')
"    return eval(old_line)

    return ''
endfunction

function! railmoon#widget#base#tab_line()
    return s:current_widget_name
endfunction

function! s:set_widget_title()
    let s:current_tab_page_number = tabpagenr()
    let s:current_widget_name = b:widget.name
    let s:current_widget_title_name = b:widget.titlename

    if ! exists('s:old_title_string')
        let s:old_title_string = &titlestring
        let s:old_gui_tab_label = &guitablabel
        let s:old_tab_line = &tabline
    endif

    let &titlestring = s:current_widget_title_name
    set guitablabel=%{railmoon#widget#base#gui_tab_label()}
    set tabline=%!railmoon#widget#base#tab_line()

    exec 'setlocal statusline='.escape(s:current_widget_name, ' ')
endfunction

function! s:restore_original_title()
    if exists('s:old_title_string')
        let &titlestring = s:old_title_string
        let &guitablabel = s:old_gui_tab_label
        let &tabline = s:old_tab_line

        unlet s:old_title_string
        unlet s:old_gui_tab_label
    endif
endfunction

" -
" [ internal usage ]
" Name: on_window_enter
" Purpose: handle gain focus event
" -
function! s:on_window_enter()
    call railmoon#trace#push('on_window_enter')
    try

    let widget = s:widget_in_auto_command()

    call s:set_widget_title()

    call railmoon#widget#base#call_back(widget, 'on_focus')

    catch /widget not found/
        call railmoon#trace#debug(v:exception)
    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

function! s:on_any_buffer_enter()
    call railmoon#trace#push('on_any_buffer_enter')
    try

    if ! railmoon#widget#handle_autocommands()
        call railmoon#trace#debug('handle autocommands stoped')
        return
    endif

    let buffer_name = expand('<afile>')
    call railmoon#trace#debug('buffer name:'.buffer_name)
    call railmoon#trace#debug('in_create_widget_state:'.s:in_create_widget_state)

    " attempt to edit file with name reserved to widget buffers
    "
    if !exists('b:widget_id') && ! s:in_create_widget_state
        call railmoon#trace#debug('b:widget not found')

        if buffer_name =~ s:buffer_name_prefix
            call railmoon#trace#debug('name of widget buffer')
            if buffer_name == expand('%')
                call railmoon#trace#debug('open alternate window')
                buffer #
            endif
        endif
    " 
    " attempt to re open widget buffer 
    elseif exists('b:widget_id') && ! s:in_create_widget_state
        call railmoon#widget#base#call_back(b:widget, 'on_setup')
        call s:redraw_widget()
    endif

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

function! s:close_ready_for_close_widgets()
    call railmoon#trace#push('s:close_ready_for_close_widgets()')
    try

    for widget in s:widget_for_close
        call railmoon#trace#debug('s:widget_for_close exists')
        
        if widget.is_closed
            call railmoon#trace#debug('already closed')
        else
            if s:close_with_tab_page 
                call railmoon#widget#base#call_back(widget, 'on_close_with_tab_page')
            else
                call railmoon#widget#base#call_back(widget, 'on_close')
            endif
            let widget.is_closed = 1

            call railmoon#id#release('railmoon_widget_id', widget.id)
        endif
    endfor
    call s:clear_widget_for_close()

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

function! s:on_any_window_enter()
    call railmoon#trace#push('on_any_window_enter')
    try

    call railmoon#trace#debug('name: '.expand('<afile>'))

    if ! railmoon#widget#handle_autocommands()
        call railmoon#trace#debug('handle autocommands stoped')
        return
    endif

    call s:close_ready_for_close_widgets()
    
    " split or something like that
    if exists('b:widget_id') && !exists('w:widget_id') && ! s:in_create_widget_state
        call railmoon#trace#debug('b:widget_id present but w:widget_id not')

        call railmoon#trace#debug('closing')
        close
    endif

    if exists('w:widget_id') && !exists('b:widget_id')
        call railmoon#trace#debug('w:widget_id present but b:widget_id not')
        close
    endif

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

" -
" [ internal usage ]
" Name: on_tab_leave
" Purpose: handle tab page lost focus event
" -
function! s:on_tab_leave()
    call railmoon#trace#push('on_window_leave')
    try

    call railmoon#widget#base#call_back(b:widget, 'on_tab_leave')

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

" -
" [ internal usage ]
" Name: on_window_leave
" Purpose: handle lost focus event
" -
function! s:on_window_leave()
    call railmoon#trace#push('on_window_leave')
    try

    if !exists('b:widget')
        call railmoon#trace#debug('b:widget not present')
        return
    endif

    if b:widget.is_closed
        call railmoon#trace#debug('already closed')
        return
    endif

    call railmoon#widget#base#call_back(b:widget, 'on_focus_lost')

    catch /.*/
        call railmoon#trace#debug(v:exception)
        call railmoon#trace#debug(v:throwpoint)

    finally
        call s:restore_original_title()

        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

" -
" [ internal usage ]
" Name: base
" Purpose: base widget object
" -
let s:base = {}

function! s:base.select()
    call railmoon#trace#push('base.select')
    try

    let id = self.id
    call railmoon#trace#debug('selecting...')
    call railmoon#widget#window#select(id)

    finally
        call railmoon#trace#debug('id = '.id)
        call railmoon#trace#pop()
    endtry
endfunction

function! s:base.close()
    call railmoon#trace#push('base.close')
    try

    if self.is_closed
        call railmoon#trace#debug('already closed')
        return
    endif

    let not_active = (w:widget_id != self.id)

    if not_active
        let selected = railmoon#widget#window#save_selected()
    endif

    call self.select()
    
    call railmoon#trace#debug('closing.. id = '.self.id)

    let window_numbers = winnr('$')
    let self.is_closed = 1
    close

    if not_active
        call railmoon#widget#window#load_selected(selected)
    endif

    call railmoon#id#release('railmoon_widget_id', self.id)

    if window_numbers > 1
        call railmoon#widget#base#call_back(self, 'on_close')
    else
        call railmoon#widget#base#call_back(self, 'on_close_with_tab_page')
    endif

    finally
        call s:close_ready_for_close_widgets()
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

call s:auto_command_setup()

