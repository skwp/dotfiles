" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#file
" Purpose: create extractor by file extension and or name

function! railmoon#oscan#extractor#file#create()
    let file_name = expand("%:p")
    let file_extension = expand("%:e")


    try
        return eval('railmoon#oscan#extractor#'.file_extension.'#'.'create()')
    catch /.*/
    endtry

    let extractor_name = 'railmoon#oscan#extractor#ctags'

    try
        let extractor = eval(extractor_name.'#'.'create()')
    catch /.*/
        echo 'extractor "'.extractor_name. '" not found. use ctags as default'
        echo '.'
        echo '.'
        echo '.'
    endtry

    return railmoon#oscan#extractor#ctags#create()
endfunction

