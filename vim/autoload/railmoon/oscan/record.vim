" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: record
" Purpose: represent record in oscan

" -
" [ plugin function ]
" Name: railmoon#oscan#record#create
" Purpose: create record
" [ parameters ]
" header            record header -- list
" tag_list          list of tags associated with record
" data              record data ( line number, or buffer number, or whatever )
" -
function! railmoon#oscan#record#create( header, tag_list, data, ... )
    let new_record = copy( s:record )
    let s:record_id += 1

    let new_record.header = a:header
    let new_record.tag_list = a:tag_list
    let new_record.data = a:data
    let new_record.id = s:record_id

    if empty(a:000)
        let new_record.additional_info = ''
    else
        let new_record.additional_info = a:1
    endif

    return new_record
endfunction

let s:record = {}
let s:record_id = 0

" -
" [ object method ]
" Object: record
" Name: has_tag
" Purpose: determine tag presence
" [ parameters ]
" tag           tag
" -
function! s:record.has_tag( tag )
    if a:tag[0] == '~'
        for l:tag in self.tag_list 
            if l:tag =~ '\c'.a:tag[1 : ]
                return 1
            endif
        endfor

        return 0
    endif

    for l:tag in self.tag_list 
        if l:tag ==? a:tag
            return 1
        endif
    endfor

    return 0
endfunction

" -
" [ object method ]
" Object: record
" Name: match_by_tags
" Purpose: determine if record match with given tags
" [ parameters ]
" tags           list of tags
" -
function! s:record.match_by_tags( tags )
    for l:tag in a:tags
        if ! self.has_tag( l:tag )
            return 0
        endif
    endfor

    return 1
endfunction 

" -
" [ object method ]
" Object: record
" Name: other_tags
" Purpose: find tags that not in list but in that record
" [ parameters ]
" tags1           list of tags
" tags2           list of tags
" -
function! s:record.other_tags( tags1, tags2 )
    let result = []

    for l:tag in self.tag_list
        let string_tag = l:tag.''

        if index(a:tags1, string_tag) == -1 && 
          \index(a:tags2, string_tag) == -1
            call add(result, string_tag)
        endif
    endfor

    return result
endfunction

" -
" [ testing ]
" -

function! s:create_test_record1()
    return railmoon#oscan#record#create( ['createTestRecord1'], [ 'edit', 'gui', 'form' ], 23 )
endfunction

function! s:create_test_record2()
    return railmoon#oscan#record#create( ['createTestRecord2'], [ 'simple', 'gui' ], 26 )
endfunction

let s:unit_test = railmoon#unit_test#create('oscan#record')

function! s:unit_test.test_record()
    call self.assert_equal(s:create_test_record1().match_by_tags(['edit']), 1)
    call self.assert_equal(s:create_test_record1().match_by_tags(['~dit']), 1)
    call self.assert_equal(s:create_test_record1().match_by_tags(['gui']), 1)
    call self.assert_equal(s:create_test_record1().match_by_tags(['form']), 1)
    call self.assert_equal(s:create_test_record1().match_by_tags(['form', 'gui']), 1)
    call self.assert_equal(s:create_test_record1().match_by_tags(['edit', 'form', 'gui']), 1)
    call self.assert_equal(! s:create_test_record1().match_by_tags(['simple', 'gui']), 1)
    call self.assert_equal(! s:create_test_record1().match_by_tags(['edit', 'fronmt', 'gui']), 1)
    call self.assert_equal(s:create_test_record1().other_tags(['edit', 'gui'], []), ['form'])
    call self.assert_equal(s:create_test_record1().other_tags(['gui'], []), ['edit', 'form'])
    call self.assert_equal(s:create_test_record1().other_tags([''], []), ['edit', 'gui', 'form'])
    call self.assert_equal(s:create_test_record1().other_tags(['edit', 'gui', 'form'], []), [])
endfunction

call s:unit_test.run()

