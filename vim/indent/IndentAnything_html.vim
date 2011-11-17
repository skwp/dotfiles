
" Source the standard indentation file, since we only want to adjust the
" default indentation.
sou $VIMRUNTIME/indent/html.vim

" Set the default indentation to be that of the standard indent file.
let b:defaultIndentExpr = &indentexpr

" Use IndentAnything
setlocal indentexpr=IndentAnything()

" Echo info about indentations
let b:indent_anything_echo = 1

"
" Adjust the default indentation for comments.  Set the comments for html to
" look like this: 
"
"       <!--
"          - comment here
"          -->
"
setl comments=sr:<!--,m:-,e:-->
let b:blockCommentStartRE  = '<!--'
let b:blockCommentMiddleRE = '-'
let b:blockCommentEndRE    = '-->'
let b:blockCommentMiddleExtra = 3

" Specify the syntax names for html comments and strings
let b:blockCommentRE = 'htmlComment'
let b:commentRE      = b:blockCommentRE

let b:stringRE            = 'htmlString'
let b:singleQuoteStringRE = b:stringRE
let b:doubleQuoteStringRE = b:stringRE
