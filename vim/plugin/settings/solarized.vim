hi! link txtBold Identifier
hi! link zshVariableDef Identifier
hi! link zshFunction Function
hi! link rubyControl Statement
hi! link rspecGroupMethods rubyControl
hi! link rspecMocks Identifier
hi! link rspecKeywords Identifier
hi! link rubyLocalVariableOrMethod Normal
hi! link rubyStringDelimiter Constant
hi! link rubyString Constant
hi! link rubyAccess Todo
hi! link rubySymbol Identifier
hi! link rubyPseudoVariable Type
hi! link rubyRailsARAssociationMethod Title
hi! link rubyRailsARValidationMethod Title
hi! link rubyRailsMethod Title
hi! link MatchParen DiffText

hi! link CTagsModule Type
hi! link CTagsClass Type
hi! link CTagsMethod Identifier

hi! link javascriptFuncName Type
hi! link javascriptFunction Statement
hi! link javascriptThis Statement
hi! link javascriptParens Normal
hi! link jOperators javascriptStringD
hi! link jId Title
hi! link jClass Title

" Brighten the regular text
hi! Normal guifg=#93a1a1
hi! Constant guifg=#00ADCE
hi! link htmlLink Include

" Enforce the colors set here
au VimEnter * so ~/.vim/plugin/settings/solarized.vim
