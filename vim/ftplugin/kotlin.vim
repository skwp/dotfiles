function! SearchFileBackwards(fn)
    let fp = expand('%:p')
    let pos = len(fp) - 1
    while pos > 0
        let pom = ""
        if fp[pos] == '/'
            let pom = strpart(fp, 0, pos + 1) . a:fn
            if filereadable(pom)
                break
            endif
        endif
        let pos = pos - 1
    endwhile
    return pom
endfunction

function! BuildMavenProject()
    let pom = SearchFileBackwards("pom.xml")
    if pom != ""
        silent exec '!mvn -f '.SearchFileBackwards("pom.xml").' compile -q &'
    else
        echohl WarningMsg | echo "No pom.xml found." | echohl None
    endif
endfunction

" comment out below line to enable automatic build on maven project.
autocmd BufWritePost *.kt :call BuildMavenProject()

" Press <F8> to build current maven project.
nnoremap <buffer> <silent> <F8> :call BuildMavenProject()<CR>
