" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Home: www.railmoon.com
" Module: railmoon#id
" Purpose: util functions for work with id
"

" -
" [ public library function ]
" Name: railmoon#id#acquire
" Purpose: return new unique id for widget
" [ parameters ]
" pool_name        id pool name
" -
function! railmoon#id#acquire(pool_name)
    if ! has_key(s:list, a:pool_name)
        let s:list[a:pool_name] = []
    endif

    if ! has_key(s:last_id, a:pool_name)
        let s:last_id[a:pool_name] = 0
    endif

    if empty(s:list[a:pool_name])
        let s:last_id[a:pool_name] += 1
        call add(s:list[a:pool_name], s:last_id[a:pool_name])
    endif

    let result = s:list[a:pool_name][0]
    let s:list[a:pool_name] = s:list[a:pool_name][1:]

    call railmoon#trace#debug('id#acquire pool = '.a:pool_name.'; id = '.result)
    return result
endfunction

" -
" [ public library function ]
" Name: railmoon#id#release
" Purpose: return id to pool
" [ parameters ]
" pool_name        id pool name
" id                id that no longer in use
" -
function! railmoon#id#release(pool_name, id)
    call railmoon#trace#debug('id#release pool = '.a:pool_name.'; id = '.a:id)
    if index(s:list[a:pool_name], a:id) != -1
        throw 'railmoon:id:release:already_present:'.a:id
    endif

    if a:id > s:last_id[a:pool_name]
        throw 'railmoon:id:release:wasnt_acquired'
    endif
    call add(s:list[a:pool_name], a:id)
endfunction

" -
" [ internal usage ]
" store last widget id
" -
let s:last_id = {}

" -
" [ internal usage ]
" store available ids
" -
let s:list = {}

" -
" Section: unit testing
" -
let s:library_unit_test = railmoon#unit_test#create('railmoon#id test')

function! s:library_unit_test.test_acquire_release()
    call self.assert_equal(railmoon#id#acquire('test_id_pool'), 1)
    call self.assert_equal(railmoon#id#acquire('test_id_pool'), 2)
    call self.assert_equal(railmoon#id#acquire('test_id_pool'), 3)

    call self.assert_equal(railmoon#id#acquire('test2_id_pool'), 1)
    call self.assert_equal(railmoon#id#acquire('test2_id_pool'), 2)
    call self.assert_equal(railmoon#id#acquire('test2_id_pool'), 3)

    call railmoon#id#release('test_id_pool', 3)
    call self.assert_equal(railmoon#id#acquire('test_id_pool'), 3)

    call railmoon#id#release('test2_id_pool', 3)
    call self.assert_equal(railmoon#id#acquire('test2_id_pool'), 3)

    call railmoon#id#release('test_id_pool', 2)
    call self.assert_equal(railmoon#id#acquire('test_id_pool'), 2)
    
    call railmoon#id#release('test_id_pool', 1)
    call self.assert_equal(railmoon#id#acquire('test_id_pool'), 1)

    call self.assert_equal(railmoon#id#acquire('test_id_pool'), 4)
    call self.assert_equal(railmoon#id#acquire('test_id_pool'), 5)
    call self.assert_equal(railmoon#id#acquire('test_id_pool'), 6)

    call railmoon#id#release('test_id_pool', 1)
    call self.assert_equal(railmoon#id#acquire('test_id_pool'), 1)

    call railmoon#id#release('test_id_pool', 1)
    call railmoon#id#release('test_id_pool', 2)
    call railmoon#id#release('test_id_pool', 3)
    call railmoon#id#release('test_id_pool', 4)
    call railmoon#id#release('test_id_pool', 5)
    call railmoon#id#release('test_id_pool', 6)
endfunction

function! s:library_unit_test.test_acquire_release_case_1()
    call self.assert_equal(railmoon#id#acquire('test_acquire_release_case_1'), 1)
    call railmoon#id#release('test_acquire_release_case_1', 1)
endfunction

call s:library_unit_test.run()

