" Some color remaps
" If statements and def statements should look similar 
" so you can see the flow 
hi! link rubyDefine rubyControl

" This is a better cursor
hi! link Cursor VisualNOS

" This is a bit nicer visual selection, and
" as a side bonus it makes CommandT look better
hi! link Visual DiffChange

" Search is way too distracting in original Solarized
hi! link Search DiffAdd

" Colors to make LustyJuggler more usable
" the Question color in LustyJuggler is mapped to
" the currently selected buffer.
hi clear Question
hi! Question guifg=yellow

hi! link TagListFileName  Question

" For jasmine.vim
hi! link specFunctions rubyDefine
hi! link specMatcher rubyConstant
hi! link specSpys rubyConstant

" Ruby, slightly better colors for solarized
hi! link rubyStringDelimiter rubyConstant
hi! link rubyInterpolationDelimiter rubyConstant
