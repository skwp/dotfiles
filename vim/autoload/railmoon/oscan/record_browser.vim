" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Module: record_browser
" Purpose: represent record browser in oscan

function! railmoon#oscan#record_browser#create( record_extractor )
    let new_record_browser = copy( s:record_browser )
    
    let new_record_browser.record_extractor = a:record_extractor
    let new_record_browser.all_records = new_record_browser.record_extractor.extract()

    return new_record_browser
endfunction

let s:record_browser = {}

function! s:record_browser.is_empty()
    return empty(self.all_records)
endfunction

" by list of tags return records that match tag list
"   record1 tags = ['method', 'create', 'button']
"   record2 tags = ['function', 'create', 'widget']
"   record3 tags = ['method', 'create', 'file']
"   tag_list = ['method', 'create']
"   result = [record1, record3]
function! s:record_browser.get_matched_records( tag_list )
    let result = []

    for record in self.all_records
        if record.match_by_tags( a:tag_list )
            call add(result, record)
        endif
    endfor

    return result
endfunction

" by list of tags return tags that can specify other records
" example:
"   record1 tags = ['method', 'create', 'button']
"   record2 tags = ['method', 'create', 'widget']
"   record3 tags = ['method', 'create', 'file']
"   tag_list = ['method', 'create']
"   result = ['widget', 'button', 'file']
function! s:record_browser.get_available_tags( tag_list ) " TODO useful?
    let result = []

    for record in self.all_records
        if record.match_by_tags( a:tag_list )
            call extend(result, record.other_tags( result, a:tag_list ))
        endif
    endfor

    return result
endfunction

" by list of tags return tags that can specify other records
" example above
function! s:record_browser.get_available_tags_for_records( matched_records, tag_list )
    let result = []

    for record in a:matched_records
        let other_tags = record.other_tags( result, a:tag_list )

        for element in other_tags
            let string_tag = element.''
            if index(result, string_tag) == -1
                call add(result, string_tag)
            endif
        endfor

"        call extend(result, record.other_tags( result, a:tag_list ))
    endfor

    return result
endfunction

" -
" [ testing ]
" -

function! s:create_test_record1()
    return railmoon#oscan#record#create( 'createTestRecord1', [ 'edit', 'gui', 'form' ], 23 )
endfunction

function! s:create_test_record2()
    return railmoon#oscan#record#create( 'createTestRecord2', [ 'simple', 'gui' ], 26 )
endfunction

let s:test_record_extractor = {}
function! s:test_record_extractor.new()
    let new_test_record_extractor = copy( s:test_record_extractor )

    let new_test_record_extractor.record1 = s:create_test_record1()
    let new_test_record_extractor.record2 = s:create_test_record2()

    let new_test_record_extractor.records = [ new_test_record_extractor.record1, new_test_record_extractor.record2 ]

    return new_test_record_extractor
endfunction

function! s:test_record_extractor.extract()
    return self.records
endfunction

let s:unit_test = railmoon#unit_test#create('oscan#record_browser')

function! s:unit_test.test_record_browser()

    let record_extractor = s:test_record_extractor.new()
    let record_browser = railmoon#oscan#record_browser#create(record_extractor)

    call self.assert_equal(len(record_browser.get_matched_records( [] )), 2)
    call self.assert_equal(len(record_browser.get_matched_records( ['simple'] )), 1)


    call self.assert_equal((record_browser.get_matched_records( ['simple'] ))[0].id, record_extractor.record2.id)
    call self.assert_equal((record_browser.get_matched_records( ['edit', 'form'] ))[0].id, record_extractor.record1.id)

    let matched_records = record_browser.get_matched_records(['gui'])
    call self.assert_equal(record_browser.get_available_tags_for_records(matched_records, ['gui']), ['edit', 'form', 'simple'])

    let matched_records = record_browser.get_matched_records(['form', 'gui'])
    call self.assert_equal(record_browser.get_available_tags_for_records(matched_records, ['form', 'gui']), ['edit'])

endfunction

call s:unit_test.run()

