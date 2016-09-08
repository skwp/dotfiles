" Python-mode
" Activate rope
" Keys:
" K             Show python docs
" <Ctrl-Space>  Rope autocomplete
" <Ctrl-c>g     Rope goto definition
" <Ctrl-c>d     Rope show documentation
" <Ctrl-c>f     Rope find occurrences
" <Leader>b     Set, unset breakpoint (g:pymode_breakpoint enabled)
" [[            Jump on previous class or function (normal, visual, operator modes)
" ]]            Jump on next class or function (normal, visual, operator modes)
" [M            Jump on previous class or method (normal, visual, operator modes)
" ]M            Jump on next class or method (normal, visual, operator modes)
let g:pymode_rope = 1

" Documentation
let g:pymode_doc = 1
" let g:pymode_doc_key = 'K'

"Linting
let g:pymode_lint = 1
" choose from pylint, pep8, mccabe, pep257, pyflakes
let g:pymode_lint_checker = "pyflakes,pep8,pylint"

"Auto check on save
let g:pymode_lint_write = 1
let g:pymode_lint_unmodified = 1

" Support virtualenv
let g:pymode_virtualenv = 1

" Enable breakpoints plugin
let g:pymode_breakpoint = 1
" let g:pymode_breakpoint_bind = '<leader>b'

" syntax highlighting
let g:pymode_syntax = 1
let g:pymode_syntax_all = 1
let g:pymode_syntax_indent_errors = g:pymode_syntax_all
let g:pymode_syntax_space_errors = g:pymode_syntax_all

" Don't autofold code
let g:pymode_folding = 0

" the default 'K' conflicts with ag search for current word
let g:pymode_doc_bind = '<leader><leader>k'

" the default '<leader>b' conflicts with ctrlP's buffer search
" and '<leader><leader>b' conflicts with EasyMotion's backward search
let g:pymode_breakpoint_bind = '<leader><leader>B'

" keep consistent with ctags's key binding
let g:pymode_rope_goto_definition_bind = "<C-]>"
let g:pymode_rope_show_doc_bind = '<C-['

" setup max line length
let g:pymode_options_max_line_length = 79

nnoremap <leader>la :PymodeLintAuto<cr>
nnoremap <leader>l :PymodeLint<cr>
nnoremap <leader>lt :PymodeLintToggle<cr>
