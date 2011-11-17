" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Home: www.railmoon.com
" Module: railmoon#widget#edit_line_window
" Purpose: provide window with callbacks for editing single line

let s:callback_object = {}
" -
" [ public library function ]
" Name: railmoon#widget#edit_line_window#create
" Purpose: create "edit line window" widget
" [ parameters ]
" name              name of new vim window that will represent widget
" titlename         name that will on title bar
" callback_object   call back object with following methods
"                       on_normal_move
"                       on_insert_move
"                       on_type(character, is_alpha_numeric) : should return character to type
"                       -- and common handlers
" -
function! railmoon#widget#edit_line_window#create(name, titlename, callback_object)
    let new_object = railmoon#widget#base#create(a:name, a:titlename, s:edit_line_window, s:callback_object, a:callback_object)

    call railmoon#trace#debug('create edit line window:'.a:name)
"    call railmoon#trace#debug(string(new_object))

    setlocal modifiable

    call s:auto_command_setup()
    call s:insert_mode_key_typing_setup()

    return new_object 
endfunction

" -
" [ internal usage ]
" Name: edit_line_window
" Purpose: widget object "edit line window"
" -
let s:edit_line_window = {}


" -
" [ object method ]
" Object: edit_line_window
" Name: get_line
" Purpose: return entered line
" -
function! s:edit_line_window.get_line()
    let selected = railmoon#widget#window#save_selected()

    call self.select()
    let text_line = getline(1)

    call railmoon#widget#window#load_selected(selected)

    return text_line
endfunction

" -
" [ object method ]
" Object: edit_line_window
" Name: set_line
" Purpose: setup text line to "edit line window"
" -
function! s:edit_line_window.set_line(line)
    let selected = railmoon#widget#window#save_selected()

    call self.select()
    call setline(1, a:line)

    call railmoon#widget#window#load_selected(selected)
endfunction

" -
" [ object method ]
" Object: edit_line_window
" Name: go_to_position
" Purpose: move cursor to specified position
" -
function! s:edit_line_window.go_to_position(position)
    call self.select()

    call cursor(1, a:position)
endfunction

" -
" [ object method ]
" Object: edit_line_window
" Name: go_to_end
" Purpose: move cursor to end
" -
function! s:edit_line_window.go_to_end()
    call self.select()
    call cursor(1, col('$'))
endfunction

" -
" [ object method ]
" Object: edit_line_window
" Name: go_to_start
" Purpose: move cursor to start of line
" -
function! s:edit_line_window.go_to_start()
    call self.select()
    call cursor(1, 1)
endfunction

" -
" [ internal usage ]
" Name: insert_mode_key_typing_setup
" Purpose: setup handlers for typing characters
" -
function! s:insert_mode_key_typing_setup()
    for item in s:alpha_numeric_characters
        execute 'inoremap <buffer> <silent> ' . item .  ' <C-R>=<SID>on_insert_typing('''.item.''', 1)<CR>'
    endfor

    for item in s:not_alpha_numeric_characters
        execute 'inoremap <buffer> <silent> ' . item .  ' <C-R>=<SID>on_insert_typing('''.item.''', 0)<CR>'
    endfor

endfunction

function! s:callback_object.on_setup()
    call s:insert_mode_key_typing_setup()
endfunction

" -
" [ internal usage ]
" Name: on_insert_typing
" Purpose: handle typing 
" -
function! s:on_insert_typing(character, is_alpha_numeric)
    let callback_object = b:widget.callback_object
    if has_key(callback_object, 'on_type')
        return callback_object.on_type( a:character, a:is_alpha_numeric )
    endif

    return a:character
endfunction

" -
" [ internal usage ]
" Name: auto_command_setup
" Purpose: setup auto commands
" -
function! s:auto_command_setup()
    autocmd CursorMoved <buffer> call s:on_cursor_moved(s:normal_mode)
    autocmd CursorMovedI <buffer> call s:on_cursor_moved(s:insert_mode)
endfunction

" -
" [ internal usage ]
" Name: on_cursor_moved
" Purpose: handle cursor movement
" -
function! s:on_cursor_moved(mode)
    if line('$') > 1
        let new_line = join(getline(1, '$'), '')
        2,$d
        call setline(1, new_line)
        call cursor(1, col('$'))
    endif

    let callback_object = w:widget.callback_object
    if a:mode == s:normal_mode
        call railmoon#widget#base#call_back(w:widget, 'on_normal_move')
    else
        call railmoon#widget#base#call_back(w:widget, 'on_insert_move')
    endif
endfunction

" -
" [ internal usage ]
" Name: normal_mode
" Purpose: enumeration of mode
" -
let s:normal_mode = 0
" -
" [ internal usage ]
" Name: insert_mode
" Purpose: enumeration of mode
" -
let s:insert_mode = 1

" -
" [ internal usage ]
" Name: alpha_numeric_characters
" Purpose: store all typing characters
" -
let s:alpha_numeric_characters = 
            \  ['a','b','c','d','e','f','g','h','i','j','k','l','m',
            \   'n','o','p','q','r','s','t','u','v','w','x','y','z',
            \   'A','B','C','D','E','F','G','H','I','J','K','L','M',
            \   'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
            \   '0','1','2','3','4','5','6','7','8','9','<space>','_','=','"',':',';','.']

" -
" [ internal usage ]
" Name: not_alpha_numeric_characters
" Purpose: store not alpha numeric characters
" -
let s:not_alpha_numeric_characters =  
        \ ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '+', '-', 
        \ '{', '}', '[', ']', "'", '<', '>', ',', '?', '`', '~', '\', '\|']

