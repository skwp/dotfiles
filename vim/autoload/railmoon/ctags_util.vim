" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Module: railmoon#ctags_util
" Purpose: some common ctags process operations


function! railmoon#ctags_util#taglist_for_file(filename, language, kinds, fields)
    let language_for_ctags = a:language
    if language_for_ctags == 'cpp'
        let language_for_ctags = 'c++'
    endif

    let kind_option = "--".language_for_ctags.'-kinds=+'.a:kinds.' --language-force='.language_for_ctags
    let field_option = '--fields='.a:fields

    if !exists('g:ctags_exe')
        let g:ctags_exe = 'ctags'
    endif

    let ctags_tmp_file_name = 't_m_p_f_i_l_e'
    let ctags_cmd = g:ctags_exe . " -n --sort=no -f " . ctags_tmp_file_name . ' ' . kind_option . ' ' . field_option . ' ' . a:filename

    call system(ctags_cmd)
    let old_tags = &tags

    let &tags = ctags_tmp_file_name
    let ctags_tags = taglist('.*')
    let &tags = old_tags

    call delete(ctags_tmp_file_name)

    return ctags_tags
endfunction

" returns not sorted tags for file treated as c++ file
function! railmoon#ctags_util#taglist_for_cppfile(filename)
    return railmoon#ctags_util#taglist_for_file(a:filename, 'c++', 'cdefgmnpstuvx', 'sikaS')
endfunction

