" These are the mappings for snipMate.vim. Putting it here ensures that it
" will be mapped after other plugins such as supertab.vim.
if exists('s:did_snips_mappings') || &cp || version < 700
	finish
endif
let s:did_snips_mappings = 1

ino <silent> <tab> <c-r>=TriggerSnippet()<cr>
snor <silent> <tab> <esc>i<right><c-r>=TriggerSnippet()<cr>
ino <silent> <c-r><tab> <c-r>=ShowAvailableSnips()<cr>
snor <bs> b<bs>
snor ' b<bs>'
snor <right> <esc>a
snor <left> <esc>bi

" By default load snippets in snippets_dir
if !exists("snippets_dir")
	finish
endif

call GetSnippets(snippets_dir, '_') " Get global snippets 

au FileType * if &ft != 'help' | call GetSnippets(snippets_dir, &ft) | endif
" vim:noet:sw=4:ts=4:ft=vim
