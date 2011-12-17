" Default to rspec 1. If you want
" rspec 2, set this to 'rspec'
let g:ruby_conque_rspec_command='spec'

" prevent auto insert mode, which is helpful when using conque
" term for running tests
"
autocmd WinEnter * stopinsert
