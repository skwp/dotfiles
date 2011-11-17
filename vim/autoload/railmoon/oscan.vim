" Author: Mykola Golubyev ( Nickolay Golubev )
" Email: golubev.nikolay@gmail.com
" Site: www.railmoon.com
" Plugin: oscan
" Purpose: quick move through current document or through any entities that can be tagged


if ! exists('g:ctags_exe')
    if exists('Tlist_Ctags_Cmd')
        let g:ctags_exe = Tlist_Ctags_Cmd
    else
        let g:ctags_exe = "ctags"
    endif
endif

let s:previous_records_to_print_count = 1
let s:previous_suggestions_count = 1
let s:records_to_print = []
let s:suggestions = []
" - 
" [ internal usage ]
" Purpose: find tag position inside line. 
"          tag can be with spaces. delimiter is comma.
"          return list with begin and end ( start from 0 ).
" [ parameters ]
"   line        string
"   column      column that starts from 1
" -
function! s:tag_in_line_position(line, column)
    let column = a:column - 1

    while a:line[column] == ',' && column > 0
        let column -= 1
    endwhile

    let begin = column 
    let end = column
    let length = len(a:line)

    while begin > 0 && a:line[begin - 1] != ','
        let begin -= 1
    endwhile

    while end < length && a:line[end + 1] != ','
        let end += 1
    endwhile

    return [begin, end]
endfunction

" - 
" [ internal usage ]
" Purpose: find tag inside line. 
"          details in function above
" [ parameters ]
"   line        string
"   column      column that starts from 1
" -
function! s:tag_in_line(line, column)
    let position = s:tag_in_line_position(a:line, a:column)

    let result = a:line[position[0] : position[1]]
    if result == ','
        return ''
    endif

    return result
endfunction

" -
" call backs for widgets
" -
let s:plugin_window_goes_close = 0
let s:common_widget_callback = {}

function! s:common_widget_callback.on_close()
    call railmoon#trace#push('common_widget_callback.on_close')
    try

        let s:plugin_window_goes_close = 1

        call s:turnon_unexpected_plugins()

        call railmoon#trace#debug('tabclose')
        tabclose

        call railmoon#widget#window#load_selected(s:plugin_invoker_position)

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

function! s:common_widget_callback.on_tab_leave()
    call railmoon#trace#push('common_widget_callback.on_tab_leave')
    try

        call railmoon#trace#debug('leaving tab')
        if ! s:plugin_window_goes_close
            let s:plugin_window_goes_close = 1
            call s:turnon_unexpected_plugins()
            tabclose " TODO make sure we close right tabpage
        endif

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

function! s:common_widget_callback.on_close_with_tab_page()
    call railmoon#trace#push('common_widget_callback.on_close_with_tab_page')
    try
    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

let s:suggestion_window_callback = copy(s:common_widget_callback)
function! s:suggestion_window_callback.on_select(line)
endfunction

let s:result_window_callback = copy(s:common_widget_callback)
function! s:result_window_callback.on_select(line)
    call s:result_select()
endfunction

let s:tag_enter_window_callback = copy(s:common_widget_callback)
let s:tag_enter_window_callback.edit_column = -1

let s:suggestion_window_model = {}
function! s:suggestion_window_model.get_item(i)
    let item = { 'data':[], 'header':'' }
    if len(s:suggestions) > 0
        call add(item.data, s:suggestions[a:i] )
    endif

    return item
endfunction

function! s:suggestion_window_model.get_item_count()
    return len(s:suggestions)
endfunction

let s:result_window_model = {}
function! s:result_window_model.get_item(i)
    if len(s:records_to_print) == 0
        return {'data':[], 'header':''}
    endif 

    let record = s:records_to_print[a:i]
    let item = { 'data':[], 'header':record.additional_info }
    call extend( item.data, record.header )
    return item
endfunction

function! s:result_window_model.get_item_count()
    return len(s:records_to_print)
endfunction

function! s:tag_enter_window_callback.on_type(character, is_alpha_numeric)
    let line = getline('.')
    let column = col('.')

    " magic with ','
    " change entered part to tag from suggestion list
    " TODO clean algorithm
    " TODO extract method and test it
    if ! a:is_alpha_numeric
        if a:character == ',' && self.available_tags_window.model.get_item_count() > 0
            let selected_tag = self.available_tags_window.selected_item()

            let position = s:tag_in_line_position(line, column)
            let begin = position[0]
            let end = position[1]
    
                
            if begin != 0
                let new_line = line[ : begin - 1] 
            else
                let new_line = ''
            endif

            let selected_tag_text = selected_tag.data[0]

            if line[end + 1] == ','
                let new_line .= selected_tag_text . line[ end + 1: ]
            else
                let new_line .= selected_tag_text . ',' . line[ end + 1 : ]
            endif

            call self.edit_line_window.set_line(new_line)
            call self.edit_line_window.go_to_position(begin + len(selected_tag_text) + 2)
        endif
        return ''
    endif

    " character isn't at line yet
    " so imagine it'is here
    let line_with_character = line[ : column] . a:character . line[column + 1 : ]
    let current_tag = s:tag_in_line(line_with_character, column)
    
    let suggestions = self.refresh_suggestion_list(current_tag, line_with_character)

    let self.edit_column = col('.') + 1
    if empty(suggestions)
        return ''
    endif

    return a:character
endfunction

function! s:suggestions_sort(lhs, rhs)
    if a:lhs == a:rhs
        return 0
    endif

    let as_current_tag_start_pattern = '^'.s:current_tag
    let number_pattern = '\d\+'

    let left_is_number = a:lhs =~ number_pattern
    let right_is_number = a:rhs =~ number_pattern

    if a:lhs =~ as_current_tag_start_pattern && a:rhs !~ as_current_tag_start_pattern
        return -1
    endif

    if left_is_number && right_is_number
        return a:lhs > a:rhs ? 1 : -1
    endif

    if left_is_number && ! right_is_number
        return 1
    endif

    if right_is_number && ! left_is_number
        return -1
    endif 

    if a:lhs !~ as_current_tag_start_pattern && a:rhs =~ as_current_tag_start_pattern
        return 1
    endif

    return a:lhs > a:rhs ? 1 : -1
endfunction

function! s:tag_enter_window_callback.refresh_suggestion_list(current_tag, line)
    let entered_tags = split(a:line, ',')

    let current_tag = a:current_tag
    if current_tag == '.'
        let current_tag = '\.'
    endif

    if current_tag =~ '"'
        call filter(entered_tags, "v:val != '". current_tag. "'")
    else
        call filter(entered_tags, 'v:val != "'.current_tag.'"')
    endif
    call add(entered_tags, '~'.current_tag)

    let available_records = s:record_browser.get_matched_records( entered_tags )
    let available_tags = s:record_browser.get_available_tags_for_records( available_records, entered_tags )

    let s:suggestions = []
    for w in available_tags
        if w =~ current_tag
            call add(s:suggestions, w)
        endif
    endfor

    let s:current_tag = current_tag
    call sort(s:suggestions, 's:suggestions_sort')

    let s:records_to_print = available_records
    let records_to_print_count = len(s:records_to_print)
    let suggestions_count = len(s:suggestions)

    if records_to_print_count != s:previous_records_to_print_count
        let self.result_window.selected_item_number = 1
    endif

    if suggestions_count != s:previous_suggestions_count
        let self.available_tags_window.selected_item_number = 1
    endif

    let s:previous_records_to_print_count = records_to_print_count
    let s:previous_suggestions_count = suggestions_count

    call self.result_window.draw()

    call self.available_tags_window.draw()

    return s:suggestions
endfunction

function! s:tag_enter_window_callback.on_enter()
endfunction

function! s:tag_enter_window_callback.on_insert_move()
    let line = getline('.')
    let column = col('.')

    if self.edit_column == column
        return
    endif

    let current_tag = s:tag_in_line(line, column)
    call self.refresh_suggestion_list(current_tag, line)
endfunction

function! s:tag_selection_up()
    call s:available_tags_window.selection_up(1)
endfunction

function! s:tag_selection_down()
    call s:available_tags_window.selection_down(1)
endfunction

function! s:result_selection_up()
    call s:result_window.selection_up(1)
endfunction

function! s:result_selection_down()
    call s:result_window.selection_down(1)
endfunction

function! s:result_select()
    call railmoon#trace#push('s:result_select')
    try

    if empty(s:records_to_print)
        return
    endif

    let selected_item_number = s:result_window.selected_item_number
    let record = s:records_to_print[selected_item_number - 1]

    let s:last_entred_tags_line = s:tag_enter_window_callback.edit_line_window.get_line()
    let s:last_selected_result_item_number = selected_item_number

    tabclose
    call railmoon#widget#window#load_selected(s:plugin_invoker_position)

    call s:record_browser.record_extractor.process(record)

    finally
        call railmoon#trace#debug('...')
        call railmoon#trace#pop()
    endtry
endfunction

function! s:close_all()
    call railmoon#trace#debug('close_all')
    call s:result_window.close()
endfunction

function! s:map_result_moving_keys()
    let result_down_keys = [ '<down>', '<C-n>', '<C-j>' ]
    let result_up_keys = [ '<up>', '<C-p>', '<C-k>' ]

    for key in result_down_keys
        let command = 'inoremap <silent> <buffer> '.key.' <C-R>=<SID>result_selection_down()?"":""<CR>'
        exec command
        let command = 'noremap <silent> <buffer> '.key.' :call <SID>result_selection_down()<CR>'
        exec command
    endfor

    for key in result_up_keys
        let command = 'inoremap <silent> <buffer> '.key.' <C-R>=<SID>result_selection_up()?"":""<CR>'
        exec command
        let command = 'noremap <silent> <buffer> '.key.' :call <SID>result_selection_up()<CR>'
        exec command
    endfor

    inoremap <silent> <buffer> <C-p> <C-R>=<SID>result_selection_up()?'':''<CR>
    inoremap <silent> <buffer> <cr> <C-R>=<SID>result_select()?' ':' '<CR>
endfunction

function! s:map_suggestion_moving_keys()
    inoremap <silent> <buffer> <Tab> <C-R>=<SID>tag_selection_down()?'':''<CR>
    inoremap <silent> <buffer> <C-Tab> <C-R>=<SID>tag_selection_up()?'':''<CR>
    noremap <silent> <buffer> <Tab> :call <SID>tag_selection_down()<CR>
    noremap <silent> <buffer> <C-Tab> :call <SID>tag_selection_up()<CR>
endfunction

function! s:map_common_keys()
    nnoremap <silent> <buffer> <esc> :call <SID>close_all()<CR>
endfunction

" information to help 0scan repeat
let s:last_extractor = {}
let s:last_record_browser = {}
let s:last_entred_tags_line = ''
let s:last_selected_result_item_number = 0


function! s:turnoff_unexpected_plugins()
    if exists('g:loaded_minibufexplorer')
        CMiniBufExplorer
    endif

    if exists('g:loaded_autocomplpop')
        call railmoon#trace#debug('Turn off autocomplpop.vim')
        AutoComplPopLock
    endif
endfunction

function! s:turnon_unexpected_plugins()
    if exists('g:loaded_autocomplpop')
        call railmoon#trace#debug('Turn on autocomplpop.vim')
        AutoComplPopUnlock
    endif
endfunction

function! s:process_last_extractor_new_selection( record_number )
    let record = s:records_to_print[ a:record_number - 1 ]
    call s:last_extractor.process(record)
endfunction

function! s:print_error( message )
    echohl Error | echo '[ 0scan ] '.a:message | echohl None
endfunction

function! s:process_last_extractor_select_next( shift )
    let records_count = len( s:records_to_print )
    let new_record_number = s:last_selected_result_item_number + a:shift

    if new_record_number < 1
        call s:print_error( 'first record reached' )
        return
    endif

    if new_record_number > records_count
        call s:print_error( "last record reached" )
        return
    endif

    let s:last_selected_result_item_number = new_record_number
    call s:process_last_extractor_new_selection( new_record_number )
endfunction

function! s:process_last_extractor_quick_selection( command )
    if a:command == 'lastup'
        call s:process_last_extractor_select_next( -1 )
    elseif a:command == 'lastdown'
        call s:process_last_extractor_select_next( 1 )
    endif
endfunction

function! s:create_extractor( name )
        let extractor = eval('railmoon#oscan#extractor#'.a:name.'#create()')
        return extractor
endfunction

" returns files from dir
"
function! s:get_filenames_from_dir( dir )
    let files_list = split( glob( a:dir."/*" ), "\n" )
    let result = []

    for item in files_list
        if filereadable( item )
            call add( result, item )
        endif
    endfor

    return result
endfunction

" returns list of [ extractor_name, extractor_description, not_implemented_flag ]
"
function! s:get_available_extractors()
    let extractor_files = []

    let vimfiles_folders = split( &runtimepath, ',' )
    for folder in vimfiles_folders
        if folder =~ 'after$'
            continue
        endif

        let extractor_folder = folder.'/autoload/railmoon/oscan/extractor'
        call extend( extractor_files, s:get_filenames_from_dir( extractor_folder ) )
    endfor

    let extractors = []

    for extractor_file in extractor_files
        "echo extractor_file
        let extractor_name = fnamemodify( extractor_file, ":t:r" )

        try
            let extractor = s:create_extractor( extractor_name )
        catch /.*/
            continue
        endtry

        let extractor_description = extractor.description
        let extractor_not_implemented = has_key( extractor, 'not_implemented' ) ? extractor.not_implemented : 0
        call add( extractors, [ extractor_name, extractor_description, extractor_not_implemented ] )
    endfor

    return extractors
endfunction

function! s:show_available_extractors()
    let extractors = s:get_available_extractors()

    let max_extractor_name_len = 0
    for extractor_description in extractors
        let len = len( extractor_description[0] )
        if len > max_extractor_name_len
            let max_extractor_name_len = len
        endif
    endfor

    echohl Comment
    echo "Please specify scan you would like you use"
    echo ":OScan scan_name [tag1] [tag2]<CR>"
    echohl None
    for extractor_description in extractors
        echohl Keyword | echo printf( "%".max_extractor_name_len."s\t", extractor_description[0] ) 

        if extractor_description[2]
            echohl Error | echon "[ Not implemented ]" | echohl None | echon " "
        endif

        echohl String | echon extractor_description[1] | echohl None
    endfor
endfunction

" completition function for :OScan command
"
function! railmoon#oscan#complete( argLead, cmdLine, cursorPos )
    let result = ''

    let extractors = s:get_available_extractors()

    for extractor_description in extractors
        if extractor_description[2]
            continue
        endif

        if ! empty( result )
            let result .= "\n"
        endif

        let result .= extractor_description[0]
    endfor

    return result
endfunction

function! railmoon#oscan#open(...)
    "call railmoon#trace#start_debug('oscan.debug')

    if empty( a:000 )
        call s:show_available_extractors()
        return
    endif

    let extractor_name = a:000[0]

    " not real extractor, but convinient way to quick run through last
    " results
    "
    if ( extractor_name == 'lastup' || extractor_name == 'lastdown' ) && !empty( s:last_extractor )
        call s:process_last_extractor_quick_selection( extractor_name )
        return
    endif

    call railmoon#trace#debug('save invoker position')

    let s:plugin_invoker_position = railmoon#widget#window#save_selected()

    call railmoon#trace#debug('create tag browser:'.extractor_name)

    let extractor = {}
    let extractor_description = ''

    let is_repeat_last_extractor = extractor_name == 'last' && ! empty(s:last_extractor)

    if is_repeat_last_extractor
        let extractor = s:last_extractor
        let extractor_description = extractor.description

        let s:record_browser = s:last_record_browser
    elseif extractor_name == 'last'
        call s:print_error( 'Nothing to repeat' )
        return
    else 
        let extractor = {}
        try
            let extractor = s:create_extractor( extractor_name )
        catch /.*/
            call s:print_error( "Can't create \"".extractor_name."\" scan" )
            return
        endtry

        let extractor_description = extractor.description

        let s:record_browser = railmoon#oscan#record_browser#create(extractor)
    endif

    if s:record_browser.is_empty()
        call s:print_error( 'no records with tags found' )
        return
    endif

    let s:last_record_browser = deepcopy(s:record_browser)
    let s:last_extractor = deepcopy(extractor)

    call railmoon#trace#debug('create new tab page')

    try
        "set lazyredraw
        silent tab help

        let width = winwidth('%')

        let s:plugin_window_goes_close = 0

        call railmoon#widget#stop_handle_autocommands()
        call s:turnoff_unexpected_plugins()

        call railmoon#trace#debug('create available_tags_window')
        let tags_window_width = width/5
        exec tags_window_width.' vsplit'

        let s:available_tags_window = railmoon#widget#selection_window#create(
            \ 'Available tags window',
            \ extractor_description,
            \ 'TODO',
            \ s:suggestion_window_model,
            \ s:suggestion_window_callback)

        call s:map_common_keys()

        call s:available_tags_window.draw()


        call railmoon#trace#debug('create result_window')
        wincmd w
        let s:result_window = railmoon#widget#selection_window#create(
            \ 'Result window',
            \ extractor_description,
            \ 'DiffAdd',
            \ s:result_window_model,
            \ s:result_window_callback)

        call s:map_common_keys()

        call extractor.colorize()

        if is_repeat_last_extractor
            call s:result_window.select_item(s:last_selected_result_item_number)
        endif

        call railmoon#trace#debug('create tag_enter_window')
        split
        resize 1
        let edit_line_window = railmoon#widget#edit_line_window#create(
            \'Tag enter window',
            \ extractor_description,
            \ s:tag_enter_window_callback)

        call s:map_common_keys()
        call s:map_result_moving_keys()
        call s:map_suggestion_moving_keys()


        if ! is_repeat_last_extractor
            let tag_line = join(a:000[ 1: ], ',')
            if len(tag_line) > 0
                let tag_line .= ','
            endif

            call edit_line_window.set_line(tag_line)
        else
            call edit_line_window.set_line(s:last_entred_tags_line)
        endif

        call railmoon#widget#window#select(edit_line_window.id)
        startinsert!
    catch /.*/
        call s:print_error( v:exception )
    finally
        call railmoon#widget#start_handle_autocommands()
        "set nolazyredraw
        "redraw
    endtry

    let s:tag_enter_window_callback.edit_line_window = edit_line_window
    let s:tag_enter_window_callback.available_tags_window = s:available_tags_window
    let s:tag_enter_window_callback.result_window = s:result_window
endfunction

" -
" [ testing ]
" -
let s:unit_test = railmoon#unit_test#create('oscan')

function! s:unit_test.test_tag_in_line()
    call self.assert_equal(s:tag_in_line('January,', 7), 'January')
    call self.assert_equal(s:tag_in_line('January,', 8), 'January')
    call self.assert_equal(s:tag_in_line('January,', 9), '')
    call self.assert_equal(s:tag_in_line('January,February', 8), 'January')
    call self.assert_equal(s:tag_in_line(',word,', 2), 'word')
    call self.assert_equal(s:tag_in_line(',word,', 3), 'word')
    call self.assert_equal(s:tag_in_line(',word,', 4), 'word')
    call self.assert_equal(s:tag_in_line(',word,', 5), 'word')
    call self.assert_equal(s:tag_in_line(',word,', 6), 'word')
    call self.assert_equal(s:tag_in_line('word,', 4), 'word')
    call self.assert_equal(s:tag_in_line('word,', 5), 'word')
    call self.assert_equal(s:tag_in_line('word,', 6), '')
    call self.assert_equal(s:tag_in_line('word,,', 6), 'word')
    call self.assert_equal(s:tag_in_line('', 1), '')
    call self.assert_equal(s:tag_in_line(',', 1), '')
endfunction

call s:unit_test.run()

