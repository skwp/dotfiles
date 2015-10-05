" These keys are easier to type than the default set
" We exclude semicolon because it's hard to read and
" i and l are too easy to mistake for each other slowing
" down recognition. The home keys and the immediate keys
" accessible by middle fingers are available 
let g:EasyMotion_keys='asdfghjklweruiovmn'
" replace vim-sneak
nmap s <Plug>(easymotion-s)
nmap f <Plug>(easymotion-bd-fl)
nmap t <Plug>(easymotion-bd-tl)
nmap <Space>w <Plug>(easymotion-bd-w)
nmap <Space>e <Plug>(easymotion-bd-e)
nmap <Space>l <Plug>(easymotion-bd-jk)
nmap <Space>j <Plug>(easymotion-jumptoanywhere)
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

" These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
" Without these mappings, `n` & `N` works fine. (These mappings just provide
" different highlight method and have some other features )
nmap  n <Plug>(easymotion-next)
nmap  N <Plug>(easymotion-prev)

" Use uppercase target labels and type as a lower case
let g:EasyMotion_use_upper = 1
 " type `l` and match `l`&`L`
let g:EasyMotion_smartcase = 1

let g:EasyMotion_force_csapprox = 1


