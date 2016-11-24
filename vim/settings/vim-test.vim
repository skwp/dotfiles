let test#strategy = "vimux"

"let test#ruby#minitest#options = '--verbose'
"let g:test#runner_commands = ['Minitest']
"let g:test#ruby#minitest#executable = 'm'

nnoremap <silent> \tf :TestFile<CR>
nnoremap <silent> \tn :TestNearest<CR>
nnoremap <silent> \ts :TestSuite<CR>
nnoremap <silent> \tl :TestLast<CR>
nnoremap <silent> \tv :TestVisit<CR>
