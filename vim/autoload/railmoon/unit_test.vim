" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Module: railmoon#unit_test
" Purpose: provide unit test object

" -
" [ public library function ]
" Name: railmoon#unit_test#create
" Purpose: create "unit test" object
" [ parameters ]
" name              name of test
" -
function! railmoon#unit_test#create(name) 
    let new_object = deepcopy(s:unit_test)
    
    let new_object.name = a:name
    let new_object.number_of_test = 0

    return new_object
endfunction

" -
" [ internal usage ]
" Name: unit_test
" Purpose: object "unit test"
" -
let s:unit_test = {}

" -
" [ object method ]
" Object: unit_test
" Name: assert_equal
" Purpose: compare two values
" -
function! s:unit_test.assert_equal(first, second)
    if !( a:second == a:first )
        throw string(a:first).' != '.string(a:second)
    endif

    let self.number_of_test += 1
endfunction

" -
" [ object method ]
" Object: unit_test
" Name: run
" Purpose: run all unit tests from suit
" -
function! s:unit_test.run()
    let test_name = ''
    try
        for key in keys(self)
            if key =~ '^test_'
                let self.number_of_test = 1
                let call_command = 'call self.'.key.'()'
                let test_name = substitute(key, '^test_\(.*\)', '\1', '')
                exec call_command
            endif
        endfor
    catch /.*/
        echohl Identifier | echo 'Suit:'.self.name | echohl None
        echohl Identifier | echo 'Test:'.test_name | echohl None
        echohl Identifier | echo 'Number:'.self.number_of_test | echohl None
        echohl Statement | echo v:exception | echohl None
        echohl Statement | echo v:throwpoint | echohl None
    endtry
endfunction

