" Vim Farben-Datei
" Ersteller:	Ingo Fabbri <vim@tcsoft.net>
" Letzte Änderung:	2003 May 13

" Mein persönliches Farbschema. Es schont die Augen, da es keine grellen Farben verwendet.
" Am Besten geignet für PHP

set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif
let colors_name = "TCSoft"

" Farb-Einstellungen für das GUI
hi Normal       guifg=#000000   guibg=#FFFFFF "Schwarze Schrift auf weißem Hintergrund

hi Ignore       guifg=bg

hi Comment      guifg=#000099   gui=italic  "dunkelblau
hi Constant     guifg=#666666   gui=NONE    "grau
hi Special      guifg=#FF0000   gui=NONE    "rot
hi Identifier   guifg=#993300   gui=NONE    "rostfarbig
hi Statement    guifg=#FF9900   gui=NONE    "orange
hi PreProc      guifg=#009900   gui=NONE    "dunkelgrün
hi Type         guifg=#FF9900   gui=bold    "orange
hi Cursor       guifg=#000000   gui=reverse "schwarz
hi LineNr       guifg=#000000   gui=NONE    "schwarz
hi StatusLine   guifg=#000000   gui=reverse,bold "schwarz

hi link   Function    PreProc
hi link   String	    Constant
hi link   Character	  Constant

hi! link  MoreMsg     Comment
hi! link  ErrorMsg    Visual
hi! link  WarningMsg  ErrorMsg
hi! link  Question    Comment

hi link   Number	    Special
hi link   Boolean	    Constant
hi link   Float		    Number

hi link   Operator    Identifier
hi link   Keyword	    Statement
hi link   Exception	  Statement
hi link   Include	    PreProc
hi link   Define	    PreProc
hi link   Macro		    PreProc

hi link   Conditional	Statement
hi link   Repeat	    Statement
hi link   Label		    Statement

hi link   PreCondit	  PreProc
hi link   StorageClass	Type
hi link   Structure	  Type
hi link   Typedef	    Type
hi link   SpecialChar	Special
hi link   Delimiter	  Special
hi link   SpecialComment Comment
hi link   Debug		    Special
