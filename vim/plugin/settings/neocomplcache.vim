" neocomplcache
" A beter autocomplete system!
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_enable_smart_case = 1

" default # of completions is 100, that's crazy
let g:neocomplcache_max_list = 5 

" words less than 3 letters long aren't worth completing
let g:neocomplcache_auto_completion_start_length = 3

" tab completion (from neocomplcache docs)
imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>"

" Choose completions using Apple-Space  
inoremap <expr><D-Space>  pumvisible() ? "\<C-n>" : "\<TAB>" 
