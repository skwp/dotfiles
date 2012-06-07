let g:ctrlp_custom_ignore = '\.git$\|\.hg$\|\.svn$'

" Default to filename searches - so that appctrl will find application
" controller
let g:ctrlp_by_filename = 1

" We don't want to use Ctrl-p as the mapping because
" it interferes with YankRing (paste, then hit ctrl-p)
let g:ctrlp_map = ',t'

" Additional mapping for buffer search
nnoremap ,b :CloseSingleConque<CR>:CtrlPBuffer<cr>
nnoremap <C-b> :CloseSingleConque<CR>:CtrlPBuffer<cr>

" Cmd-Shift-P to clear the cache
nnoremap <silent> <D-P> :ClearCtrlPCache<cr>

" Idea from : http://www.charlietanksley.net/blog/blog/2011/10/18/vim-navigation-with-lustyexplorer-and-lustyjuggler/
" Open CtrlP starting from a particular path, making it much
" more likely to find the correct thing first. mnemonic 'jump to [something]'
map ,jm :CloseSingleConque<CR>:CtrlP app/models<CR>
map ,jc :CloseSingleConque<CR>:CtrlP app/controllers<CR>
map ,jv :CloseSingleConque<CR>:CtrlP app/views<CR>
map ,jh :CloseSingleConque<CR>:CtrlP app/helpers<CR>
map ,jl :CloseSingleConque<CR>:CtrlP lib<CR>
map ,jp :CloseSingleConque<CR>:CtrlP public<CR>
map ,js :CloseSingleConque<CR>:CtrlP spec<CR>
map ,jf :CloseSingleConque<CR>:CtrlP fast_spec<CR>
map ,jd :CloseSingleConque<CR>:CtrlP db<CR>
map ,jC :CloseSingleConque<CR>:CtrlP config<CR>
map ,jV :CloseSingleConque<CR>:CtrlP vendor<CR>
map ,jF :CloseSingleConque<CR>:CtrlP factories<CR>
map ,jT :CloseSingleConque<CR>:CtrlP test<CR>

"Cmd-(m)ethod - jump to a method (tag in current file)
map ,m :CloseSingleConque<CR>:CtrlPBufTag<CR>

"Ctrl-(M)ethod - jump to a method (tag in all files)
map ,M :CloseSingleConque<CR>:CtrlPBufTagAll<CR>
