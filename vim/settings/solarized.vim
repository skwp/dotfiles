if !exists("g:yadr_disable_solarized_enhancements")
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
  hi! link rubyDoBlock Normal
  hi! link MatchParen DiffText

  hi! link CTagsModule Type
  hi! link CTagsClass Type
  hi! link CTagsMethod Identifier
  hi! link CTagsSingleton Identifier

  hi! link javascriptFuncName Type
  hi! link jsFuncCall jsFuncName
  hi! link javascriptFunction Statement
  hi! link javascriptThis Statement
  hi! link javascriptParens Normal
  hi! link jOperators javascriptStringD
  hi! link jId Title
  hi! link jClass Title

  " Javascript language support
  hi! link javascriptJGlobalMethod Statement

  " Make the braces and other noisy things slightly less noisy
  hi! jsParens guifg=#005F78 cterm=NONE term=NONE ctermfg=NONE ctermbg=NONE
  hi! link jsFuncParens jsParens
  hi! link jsFuncBraces jsParens
  hi! link jsBraces jsParens
  hi! link jsParens jsParens
  hi! link jsNoise jsParens

  hi! link NERDTreeFile Constant
  hi! link NERDTreeDir Identifier

  hi! link sassMixinName Function
  hi! link sassDefinition Function
  hi! link sassProperty Type
  hi! link htmlTagName Type

  hi! PreProc gui=bold

  " Solarized separators are a little garish.
  " This moves separators, comments, and normal
  " text into the same color family as the background.
  " Using the http://drpeterjones.com/colorcalc/,
  " they are now just differently saturated and
  " valued riffs on the background color, making
  " everything play together just a little more nicely.
  hi! VertSplit guifg=#003745 cterm=NONE term=NONE ctermfg=NONE ctermbg=NONE
  hi! LineNR guifg=#004C60 gui=bold guibg=#002B36 ctermfg=146
  hi! link NonText VertSplit
  hi! Normal guifg=#77A5B1
  hi! Constant guifg=#00BCE0
  hi! Comment guifg=#52737B
  hi! link htmlLink Include
  hi! CursorLine cterm=NONE gui=NONE
  hi! Visual ctermbg=233
  hi! Type gui=bold
  hi! EasyMotionTarget guifg=#4CE660 gui=bold

  " Make sure this file loads itself on top of any other color settings
  au VimEnter * so ~/.vim/settings/solarized.vim
endif
