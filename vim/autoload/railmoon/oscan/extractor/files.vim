" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#files
" Purpose: extract files from current file directory to open

function! railmoon#oscan#extractor#files#create()
    let new_extractor = copy(s:tag_scan_files_extractor)

    let file_name = expand("%:p")
    let new_extractor.current_file_dir = fnamemodify(file_name, ":p:h")

    let new_extractor.description = 'Select file from "'.new_extractor.current_file_dir.'" directory to open'

    return new_extractor
endfunction

let s:tag_scan_files_extractor = {}
function! s:tag_scan_files_extractor.process(record)
    if &modified
        let choice = inputlist( [ "Buffer is modified.", "1. Save current and continue" , "2. Break", "3. Open in new tab" ] )
        if 1 == choice
            update
        elseif 2 == choice
            return
        elseif 3 == choice
            tab new
        else 
            tab new
        endif
    endif

    let buf_number = bufnr(a:record.data)
    if -1 == buf_number
        exec 'edit '.escape(a:record.data,' ')
    else
        exec 'buffer '.buf_number
    endif
endfunction

function! s:tag_scan_files_extractor.tags_by_name(buffer_name, buffer_number)
    let tags = railmoon#oscan#extractor#util#tags_from_file_name(a:buffer_name)

    if index(tags, string(a:buffer_number)) == -1
        call add(tags, a:buffer_number)
    endif

    return tags
endfunction

function! s:tag_scan_files_extractor.header_by_name(buffer_name, buffer_number)
    return [  a:buffer_name ]
endfunction

function! s:tag_scan_files_extractor.extract()
    let result = []

    let files = split(glob( self.current_file_dir."/*" ), "\n")
    "call extend(files, split(glob( self.current_file_dir."/.*" ), "\n"))

    for file in files

        if ! filereadable(file)
            continue
        endif

        let just_name = fnamemodify(file, ":t:r")
        let ext = fnamemodify(file, ":e")

        let tags = [ just_name, ext ]

        call add(result, railmoon#oscan#record#create( [ just_name ],
                    \ tags,
                    \ file,
                    \ ext))

    endfor


    return result
endfunction

function! s:tag_scan_files_extractor.colorize()
endfunction

