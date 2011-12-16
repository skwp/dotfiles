" Run the current file in a ConqueTerm, great for ruby tests
let g:ConqueTerm_InsertOnEnter = 0
let g:ConqueTerm_CWInsert = 1
let g:ConqueTerm_Color = 2

" Open up a variety of commands in the ConqueTerm
nmap <silent> <Leader>cc :execute 'ConqueTermSplit script/console --irb=pry'<CR>
nmap <silent> <Leader>pp :execute 'ConqueTermSplit pry'<CR>
nmap <silent> <Leader>zz :execute 'ConqueTermSplit zsh'<CR>

let g:ConqueTerm_SendVisKey = '<Leader>e'
