autocmd BufNewFile,BufRead *rb call s:CheckForSinatraApp()

function! s:CheckForSinatraApp()
    if &filetype !~ '\(^sinatra$\|\.sinatra$\|^sinatra\.\|\.sinatra\.\)'
        if search('Sinatra::Base\|require\s*[''"]sinatra[''"]', 'nwc') != 0
            let &filetype = &filetype . ".sinatra"
        endif
    endif
endfunction
