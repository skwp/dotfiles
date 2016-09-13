"mark syntax errors with :signs
let g:syntastic_enable_signs=1
"automatically jump to the error when saving the file
let g:syntastic_auto_jump=0
"show the error list automatically
let g:syntastic_auto_loc_list=1
"don't care about warnings
let g:syntastic_quiet_messages = {'level': 'warnings'}

"
" Javascript
"

let g:syntastic_javascript_checkers = []

function CheckJavaScriptLinter(filepath, linter)
  if exists('b:syntastic_checkers')
    return
  endif
  if filereadable(a:filepath)
    let b:syntastic_checkers = [a:linter]
    let {'b:syntastic_' . a:linter . '_exec'} = a:filepath
  endif
endfunction

function SetupJavaScriptLinter()
    let l:current_folder = expand('%:p:h')
    let l:bin_folder = fnamemodify(syntastic#util#findFileInParent('package.json', l:current_folder), ':h')
    let l:bin_folder = l:bin_folder . '/node_modules/.bin/'
    call CheckJavaScriptLinter(l:bin_folder . 'standard', 'standard')
    call CheckJavaScriptLinter(l:bin_folder . 'eslint', 'eslint')
endfunction

autocmd FileType javascript call SetupJavaScriptLinter()

"
" Ruby
"

" I have no idea why this is not working, as it used to
" be a part of syntastic code but was apparently removed
" This will make syntastic find the correct ruby specified by mri
function! s:FindRubyExec()
    if executable("rvm")
        return system("rvm tools identifier")
    endif

    return "ruby"
endfunction

if !exists("g:syntastic_ruby_exec")
    let g:syntastic_ruby_exec = s:FindRubyExec()
endif
