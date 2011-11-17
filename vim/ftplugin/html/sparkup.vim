" Sparkup
" Installation:
"    Copy the contents of vim/ftplugin/ to your ~/.vim/ftplugin directory.
"
"        $ cp -R vim/ftplugin ~/.vim/ftplugin/
"
" Configuration:
"   g:sparkup (Default: 'sparkup') -
"     Location of the sparkup executable. You shouldn't need to change this
"     setting if you used the install option above.
"
"   g:sparkupArgs (Default: '--no-last-newline') -
"     Additional args passed to sparkup.
"
"   g:sparkupExecuteMapping (Default: '<c-e>') -
"     Mapping used to execute sparkup.
"
"   g:sparkupNextMapping (Default: '<c-n>') -
"     Mapping used to jump to the next empty tag/attribute.

if !exists('g:sparkupExecuteMapping')
  let g:sparkupExecuteMapping = '<c-e>'
endif

if !exists('g:sparkupNextMapping')
  let g:sparkupNextMapping = '<c-n>'
endif

exec 'nmap <buffer> ' . g:sparkupExecuteMapping . ' :call <SID>Sparkup()<cr>'
exec 'imap <buffer> ' . g:sparkupExecuteMapping . ' <c-g>u<Esc>:call <SID>Sparkup()<cr>'
exec 'nmap <buffer> ' . g:sparkupNextMapping . ' :call <SID>SparkupNext()<cr>'
exec 'imap <buffer> ' . g:sparkupNextMapping . ' <c-g>u<Esc>:call <SID>SparkupNext()<cr>'

if exists('*s:Sparkup')
    finish
endif

function! s:Sparkup()
    if !exists('s:sparkup')
        let s:sparkup = exists('g:sparkup') ? g:sparkup : 'sparkup'
        let s:sparkupArgs = exists('g:sparkupArgs') ? g:sparkupArgs : '--no-last-newline'
        " check the user's path first. if not found then search relative to
        " sparkup.vim in the runtimepath.
        if !executable(s:sparkup)
            let paths = substitute(escape(&runtimepath, ' '), '\(,\|$\)', '/**\1', 'g')
            let s:sparkup = findfile('sparkup.py', paths)

            if !filereadable(s:sparkup)
                echohl WarningMsg
                echom 'Warning: could not find sparkup on your path or in your vim runtime path.'
                echohl None
                finish
            endif
        endif
        let s:sparkup = '"' . s:sparkup . '"'
        let s:sparkup .= printf(' %s --indent-spaces=%s', s:sparkupArgs, &shiftwidth)
        if has('win32') || has('win64')
            let s:sparkup = 'python ' . s:sparkup
        endif
    endif
    exec '.!' . s:sparkup
    call s:SparkupNext()
endfunction

function! s:SparkupNext()
    " 1: empty tag, 2: empty attribute, 3: empty line
    let n = search('><\/\|\(""\)\|^\s*$', 'Wp')
    if n == 3
        startinsert!
    else
        execute 'normal l'
        startinsert
    endif
endfunction
