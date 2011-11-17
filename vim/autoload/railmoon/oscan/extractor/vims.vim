" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#vims
" Purpose: extract vim servers to select

function! railmoon#oscan#extractor#vims#create()
    let new_extractor = copy(s:tag_scan_vim_extractor)
    let new_extractor.last_buffer_number = bufnr('$')
    let new_extractor.buffer_number_width = len(line('$'))
    let new_extractor.description = "Select buffer to edit among all opened Vims"

    return new_extractor
endfunction

function! railmoon#oscan#extractor#vims#select_buffer(buffer_number)

    let current_tabpage = tabpagenr()
    let current_window = winnr()

    for tabpage_number in range(1, tabpagenr('$'))
        exec (tabpage_number) . 'tabnext'
        
        for window_number in range(1, winnr('$'))

            let buffer_number = winbufnr(window_number)

            if buffer_number == a:buffer_number
                exec (window_number) . 'wincmd w'
                return
            endif
        endfor 
    endfor

    exec (current_tabpage) . 'tabnext'
    exec (current_window) . 'wincmd w'
endfunction

let s:tag_scan_vim_extractor = {}
function! s:tag_scan_vim_extractor.process(record)
    let server_name = a:record.data[0]
    let buffer_number = a:record.data[1]

    call remote_foreground(server_name)
    call remote_expr(server_name, 'railmoon#oscan#extractor#vims#select_buffer('.buffer_number.')')
endfunction

function! s:tag_scan_vim_extractor.extract()
    let result = []

    let vim_servers = split(serverlist(), "\n")

    for servername in vim_servers
        "echo servername
        "redraw
        let buffers_result = remote_expr(servername, 'railmoon#oscan#extractor#util#buffer_list()')
        let buffers_result = '['.join(split(buffers_result, "\n"), ',').']'

        let buffers_list = eval(buffers_result)

        for buffer_info in buffers_list

            let tags = [ servername ]
            let buffer_number = buffer_info[0]
            let buffer_name = buffer_info[1]

            call add(tags, fnamemodify(buffer_name, ':p:t'))

            call add(result, railmoon#oscan#record#create( [ buffer_name ],
                        \ tags,
                        \ [ servername, buffer_number ],
                        \ servername))

        endfor

    endfor

    return result
endfunction

function! s:tag_scan_vim_extractor.colorize()
endfunction

