" Some color remaps
" If statements and def statements should look similar 
" so you can see the flow 
hi! link rubyDefine rubyControl

" This is a bit nicer visual selection, and
" as a side bonus it makes CommandT look better
hi! link Visual DiffChange

" Colors to make LustyJuggler more usable
" the Question color in LustyJuggler is mapped to
" the currently selected buffer.
hi clear Question
hi! Question guifg=yellow

hi! link TagListFileName  Question
