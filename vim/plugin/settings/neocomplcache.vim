" neocomplcache
" A beter autocomplete system!
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_min_syntax_length = 5

" Choose completions using Apple-Space  
inoremap <expr><D-Space>  pumvisible() ? "\<C-n>" : "\<TAB>" 
