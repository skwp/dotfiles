" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: extractor#taglist_by_ooo
" Purpose: extract records by object oriented type. 

function! railmoon#oscan#extractor#taglist_by_ooo#create()
    return railmoon#oscan#extractor#taglist_by_type#create('s')
endfunction

