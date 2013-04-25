"
" Vim color scheme - marelo
" Created by Luiz Gonzaga dos Santos Filho - github.com/lfilho
" Initially based on "darkdevel" colorscheme
"
if !has("gui_macvim")
  set t_Co=256
  let g:solarized_termcolors=256
endif

set linespace=3

let g:colors_name = "marelo"

"hi IncSearch -- no settings --
hi WildMenu guifg=#00ff00 guibg=#ffff00 guisp=#ffff00 gui=NONE ctermfg=10 ctermbg=11 cterm=NONE
"hi SignColumn -- no settings --
hi SpecialComment guifg=#E18964 guibg=NONE guisp=NONE gui=NONE ctermfg=173 ctermbg=NONE cterm=NONE
hi Typedef guifg=#FFFFB6 guibg=NONE guisp=NONE gui=NONE ctermfg=229 ctermbg=NONE cterm=NONE
hi Title guifg=#f6f3e8 guibg=NONE guisp=NONE gui=bold ctermfg=230 ctermbg=NONE cterm=bold
hi Folded guifg=#cccccc guibg=#384048 guisp=#384048 gui=NONE ctermfg=252 ctermbg=238 cterm=NONE
hi PreCondit guifg=#96CBFE guibg=NONE guisp=NONE gui=NONE ctermfg=117 ctermbg=NONE cterm=NONE
hi Include guifg=#96CBFE guibg=NONE guisp=NONE gui=NONE ctermfg=117 ctermbg=NONE cterm=NONE
hi Float guifg=#00af00 guibg=NONE guisp=NONE gui=NONE ctermfg=34 ctermbg=NONE cterm=NONE
hi StatusLineNC guifg=#585858 guibg=#202020 guisp=#202020 gui=NONE ctermfg=240 ctermbg=234 cterm=NONE
"hi CTagsMember -- no settings --
hi NonText guifg=#070707 guibg=#000000 guisp=#000000 gui=NONE ctermfg=232 ctermbg=NONE cterm=NONE
"hi CTagsGlobalConstant -- no settings --
hi DiffText guifg=#c0c0c0 guibg=#af0000 guisp=#af0000 gui=bold ctermfg=7 ctermbg=124 cterm=bold
hi ErrorMsg guifg=#eeeeee guibg=#af0000 guisp=#af0000 gui=NONE ctermfg=255 ctermbg=124 cterm=NONE
"hi Ignore -- no settings --
hi Debug guifg=#E18964 guibg=NONE guisp=NONE gui=NONE ctermfg=173 ctermbg=NONE cterm=NONE
hi PMenuSbar guifg=#000000 guibg=#ffffff guisp=#ffffff gui=NONE ctermfg=0 ctermbg=15 cterm=NONE
hi Identifier guifg=#5f87d7 guibg=NONE guisp=NONE gui=NONE ctermfg=68 ctermbg=NONE cterm=NONE
hi SpecialChar guifg=#E18964 guibg=NONE guisp=NONE gui=NONE ctermfg=173 ctermbg=NONE cterm=NONE
hi Conditional guifg=#6699CC guibg=NONE guisp=NONE gui=NONE ctermfg=68 ctermbg=NONE cterm=NONE
hi StorageClass guifg=#FFFFB6 guibg=NONE guisp=NONE gui=NONE ctermfg=229 ctermbg=NONE cterm=NONE
hi Todo guifg=#c00000 guibg=NONE guisp=NONE gui=bold ctermfg=1 ctermbg=NONE cterm=bold
hi Special guifg=#E18964 guibg=NONE guisp=NONE gui=NONE ctermfg=173 ctermbg=NONE cterm=NONE
hi LineNr guifg=#3D3D3D guibg=#000000 guisp=#000000 gui=NONE ctermfg=237 ctermbg=NONE cterm=NONE
hi StatusLine guifg=#CCCCCC guibg=#202020 guisp=#202020 gui=italic ctermfg=252 ctermbg=234 cterm=NONE
hi Normal guifg=#f6f3e8 guibg=#000000 guisp=#000000 gui=NONE ctermfg=230 ctermbg=NONE cterm=NONE
hi Label guifg=#6699CC guibg=NONE guisp=NONE gui=NONE ctermfg=68 ctermbg=NONE cterm=NONE
"hi CTagsImport -- no settings --
hi PMenuSel guifg=#000000 guibg=#cae682 guisp=#cae682 gui=NONE ctermfg=0 ctermbg=150 cterm=NONE
hi Search guifg=#ffffff guibg=#6699cc guisp=#6699cc gui=underline ctermfg=15 ctermbg=68 cterm=underline
"hi CTagsGlobalVariable -- no settings --
hi Delimiter guifg=#00A0A0 guibg=NONE guisp=NONE gui=NONE ctermfg=37 ctermbg=NONE cterm=NONE
hi Statement guifg=#6699CC guibg=NONE guisp=NONE gui=NONE ctermfg=68 ctermbg=NONE cterm=NONE
"hi SpellRare -- no settings --
"hi EnumerationValue -- no settings --
hi Comment guifg=#949494 guibg=NONE guisp=NONE gui=italic ctermfg=246 ctermbg=NONE cterm=NONE
hi Character guifg=#99CC99 guibg=NONE guisp=NONE gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
"hi TabLineSel -- no settings --
hi Number guifg=#00af00 guibg=NONE guisp=NONE gui=NONE ctermfg=34 ctermbg=NONE cterm=NONE
hi Boolean guifg=#99CC99 guibg=NONE guisp=NONE gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi Operator guifg=#ffffff guibg=NONE guisp=NONE gui=bold ctermfg=15 ctermbg=NONE cterm=bold
hi CursorLine guifg=NONE guibg=#121212 guisp=#121212 gui=bold ctermfg=NONE ctermbg=233 cterm=bold
"hi Union -- no settings --
"hi TabLineFill -- no settings --
"hi Question -- no settings --
hi WarningMsg guifg=#ffffff guibg=#FF6C60 guisp=#FF6C60 gui=NONE ctermfg=15 ctermbg=9 cterm=NONE
"hi VisualNOS -- no settings --
hi DiffDelete guifg=#b2b2b2 guibg=#767676 guisp=#767676 gui=NONE ctermfg=249 ctermbg=243 cterm=NONE
hi ModeMsg guifg=#000000 guibg=#C6C5FE guisp=#C6C5FE gui=NONE ctermfg=0 ctermbg=189 cterm=NONE
hi CursorColumn guifg=NONE guibg=#121212 guisp=#121212 gui=NONE ctermfg=NONE ctermbg=233 cterm=NONE
hi Define guifg=#96CBFE guibg=NONE guisp=NONE gui=NONE ctermfg=117 ctermbg=NONE cterm=NONE
hi Function guifg=#d78700 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
"hi FoldColumn -- no settings --
hi PreProc guifg=#96CBFE guibg=NONE guisp=NONE gui=NONE ctermfg=117 ctermbg=NONE cterm=NONE
"hi EnumerationName -- no settings --
hi Visual guifg=NONE guibg=#003e85 guisp=#003e85 gui=NONE ctermfg=NONE ctermbg=24 cterm=NONE
"hi MoreMsg -- no settings --
"hi SpellCap -- no settings --
hi VertSplit guifg=#202020 guibg=#202020 guisp=#202020 gui=NONE ctermfg=234 ctermbg=234 cterm=NONE
hi Exception guifg=#0087ff guibg=NONE guisp=NONE gui=NONE ctermfg=33 ctermbg=NONE cterm=NONE
hi Keyword guifg=#96CBFE guibg=NONE guisp=NONE gui=NONE ctermfg=117 ctermbg=NONE cterm=NONE
hi Type guifg=#fcfcc7 guibg=NONE guisp=NONE gui=NONE ctermfg=229 ctermbg=NONE cterm=NONE
hi DiffChange guifg=#CCCCCC guibg=#5c0202 guisp=#5c0202 gui=NONE ctermfg=252 ctermbg=52 cterm=NONE
hi Cursor guifg=#000000 guibg=#ffffff guisp=#ffffff gui=NONE ctermfg=0 ctermbg=15 cterm=NONE
"hi SpellLocal -- no settings --
"hi Error -- no settings --
hi PMenu guifg=#f6f3e8 guibg=#444444 guisp=#444444 gui=NONE ctermfg=230 ctermbg=238 cterm=NONE
hi SpecialKey guifg=#808080 guibg=#343434 guisp=#343434 gui=NONE ctermfg=8 ctermbg=236 cterm=NONE
hi Constant guifg=#99CC99 guibg=NONE guisp=NONE gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
"hi DefinedName -- no settings --
hi Tag guifg=#E18964 guibg=NONE guisp=NONE gui=NONE ctermfg=173 ctermbg=NONE cterm=NONE
hi String guifg=#A8FF60 guibg=NONE guisp=NONE gui=NONE ctermfg=155 ctermbg=NONE cterm=NONE
hi PMenuThumb guifg=NONE guibg=#3D3D3D guisp=#3D3D3D gui=NONE ctermfg=NONE ctermbg=237 cterm=NONE
hi MatchParen guifg=#f6f3e8 guibg=#857b6f guisp=#857b6f gui=NONE ctermfg=230 ctermbg=101 cterm=NONE
"hi LocalVariable -- no settings --
hi Repeat guifg=#6699CC guibg=NONE guisp=NONE gui=NONE ctermfg=68 ctermbg=NONE cterm=NONE
"hi SpellBad -- no settings --
"hi CTagsClass -- no settings --
"hi Directory -- no settings --
hi Structure guifg=#FFFFB6 guibg=NONE guisp=NONE gui=NONE ctermfg=229 ctermbg=NONE cterm=NONE
hi Macro guifg=#96CBFE guibg=NONE guisp=NONE gui=NONE ctermfg=117 ctermbg=NONE cterm=NONE
"hi Underlined -- no settings --
hi DiffAdd guifg=#ffffff guibg=#005fd7 guisp=#005fd7 gui=NONE ctermfg=15 ctermbg=26 cterm=NONE
"hi TabLine -- no settings --
hi rubyescape guifg=#ffffff guibg=NONE guisp=NONE gui=NONE ctermfg=15 ctermbg=NONE cterm=NONE
hi rubyregexpdelimiter guifg=#FF8000 guibg=NONE guisp=NONE gui=NONE ctermfg=208 ctermbg=NONE cterm=NONE
hi rubyinterpolationdelimiter guifg=#00A0A0 guibg=NONE guisp=NONE gui=NONE ctermfg=37 ctermbg=NONE cterm=NONE
hi rubystringdelimiter guifg=#336633 guibg=NONE guisp=NONE gui=NONE ctermfg=65 ctermbg=NONE cterm=NONE
hi rubyregexp guifg=#B18A3D guibg=NONE guisp=NONE gui=NONE ctermfg=137 ctermbg=NONE cterm=NONE
hi rubycontrol guifg=#6699CC guibg=NONE guisp=NONE gui=NONE ctermfg=68 ctermbg=NONE cterm=NONE
hi longlinewarning guifg=NONE guibg=#371F1C guisp=#371F1C gui=underline ctermfg=NONE ctermbg=237 cterm=underline
hi javadocseetag guifg=#CCCCCC guibg=NONE guisp=NONE gui=NONE ctermfg=252 ctermbg=NONE cterm=NONE
"hi clear -- no settings --

"
" Links
"
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

hi! link CTagsModule Type
hi! link CTagsClass Type
hi! link CTagsMethod Identifier
hi! link CTagsSingleton Identifier

hi! link javascriptFuncName Normal
hi! link jsFuncBlock Type
hi! link javaScriptNumber Number
hi! link javascriptFunction Function
hi! link javascriptThis Keyword
hi! link javascriptParens Normal

hi! link jsFuncName javascriptFuncName
hi! link jsNumber javaScriptNumber
hi! link jsFunction javascriptFunction
hi! link jsFunc javascriptFunction
hi! link jsThis javascriptThis
hi! link jsParen javascriptParens
hi! link jsType Special
hi! link jsReturn Special

hi! link jOperators javascriptStringD
hi! link jId Title
hi! link jClass Title

hi! link NERDTreeFile Constant
hi! link NERDTreeDir Identifier

hi! link sassMixinName Function
hi! link sassDefinition Function
hi! link sassProperty Type
hi! link htmlTagName Type

hi! PreProc gui=bold
hi! Type gui=bold

hi! SignColumn guibg=NONE
