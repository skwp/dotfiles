" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Module: railmoon#widget#canvas
" Purpose: widget for drawing inside it 

" -
" [ internal usage ]
" Name: callback_object
" Purpose: handler for base back calls
" -
let s:callback_object = {}

" -
" [ public library function ]
" Name: railmoon#widget#canvas#create
" Purpose: create "canvas" widget
" [ parameters ]
" name              name of new vim window that will represent widget
" callback_object   call back object with following methods
"                       on_draw()   draw what inside canvas
" -
function! railmoon#widget#canvas#create(name, callback_object)
    let new_object = railmoon#widget#base#create(a:name, s:canvas, [a:callback_object, s:callback_object])
    
    call s:auto_command_setup()

    return new_object
endfunction

" -
" [ internal usage ]
" Name: auto_command_setup
" Purpose: setup handlers for window triggers
" -
function! s:auto_command_setup()
"    autocmd CursorMoved <buffer> call s:on_cursor_moved()
endfunction

function! s:callback_object.on_setup()
endfunction

" -
" [ internal usage ]
" Name: canvas
" Purpose: widget object "canvas"
" -
let s:canvas = {}

" -
" [ object method ]
" Object: canvas
" Name: draw
" Purpose: prepare_canvas for drawing and call user defined on_draw method
" -
function! s:canvas.draw()
    call railmoon#trace#push('canvas.draw')
    try

    let selected = railmoon#widget#window#save_selected()
    let is_selected = railmoon#widget#window#select(self.id)

    if ! is_selected
        throw 'widget:selection_window:draw:window_not_found'
    endif

    setlocal modifiable

    0,$delete _
    call railmoon#draw#prepare_canvas(winwidth('%'), winheight('%'))
    call railmoon#widget#base#call_back(self, 'on_draw()')

    setlocal nomodifiable

    call railmoon#widget#window#load_selected(selected)

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

