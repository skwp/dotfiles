" Some color remaps
" If statements and def statements should look similar 
" so you can see the flow 
hi! link rubyDefine rubyControl

" Colors to make LustyJuggler more usable
" the Question color in LustyJuggler is mapped to
" the currently selected buffer.
hi clear Question
hi! Question guifg=yellow

hi! link TagListFileName  Question
