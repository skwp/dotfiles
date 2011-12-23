let g:CommandTMaxHeight = 5
let g:CommandTMatchWindowReverse = 1

" Command-T
" Mapped to ,t
nmap ,t :CommandT<CR>
nmap ,T :CommandTBuffer<CR>

" Idea from : http://www.charlietanksley.net/blog/blog/2011/10/18/vim-navigation-with-lustyexplorer-and-lustyjuggler/
" Open CommandT starting from a particular path, making it much 
" more likely to find the correct thing first. mnemonic 'jump to [something]'
map ,jm :CommandT app/models<CR>
map ,jc :CommandT app/controllers<CR>
map ,jv :CommandT app/views<CR>
map ,jh :CommandT app/helpers<CR>
map ,jl :CommandT lib<CR>
map ,jp :CommandT public<CR>
map ,js :CommandT spec<CR>
map ,jf :CommandT fast_spec<CR>
map ,jt :CommandT test<CR>
map ,jd :CommandT db<CR>
map ,jC :CommandT config<CR>
map ,jV :CommandT vendor<CR>
map ,jF :CommandT factories<CR>
