" Make it beautiful - colors and fonts

" http://ethanschoonover.com/solarized/vim-colors-solarized
let s:myTheme='solarized'
exec 'colorscheme ' . s:myTheme

" If there's a custom powerline theme too, load it. Otherwise load the
" solarized one just so it won't look very bad.
let s:powerlineCustom="~/.vim/colors-settings/" . s:myTheme . "-powerline.vim"
if filereadable(expand(s:powerlineCustom))
  exec "au VimEnter * so " . s:powerlineCustom
else
  exec "au VimEnter * so ~/.vim/colors-settings/solarized-powerline.vim"
endif

let s:colorSchemeCustom="~/.vim/colors-settings/" . s:myTheme . ".vim"
if filereadable(expand(s:colorSchemeCustom))
  exec "au VimEnter * so " . s:colorSchemeCustom
endif


set background=dark

if has("gui_running")
  "tell the term has 256 colors
  set t_Co=256

  " Show tab number (useful for Cmd-1, Cmd-2.. mapping)
  " For some reason this doesn't work as a regular set command,
  " (the numbers don't show up) so I made it a VimEnter event
  autocmd VimEnter * set guitablabel=%N:\ %t\ %M

  set lines=60
  set columns=190

  set guifont=Inconsolata\ XL:h17,Inconsolata:h20,Monaco:h17
else
  "dont load csapprox if we no gui support - silences an annoying warning
  let g:CSApprox_loaded = 1
endif

