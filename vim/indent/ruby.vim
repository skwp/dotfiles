"
" Copyright 2009 IGREQUE IGREQUE, All rights reserved.
" 
" Lisence: BSD
"
" Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
" 
"     * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
"     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
"     * Neither the name of the IGREQUE IGREQUE nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
" 
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
" 

"
" Script:
"
"   Ruby Indentation with IndentAnything
"
" Version: 0.1.6
"
" Description:
"  This script requires IndentAnything version 1.2.2 or above.
"  See http://www.vim.org/scripts/script.php?script_id=1839 .
"
" Installation:
"
"   Copy this file in your home directory under ~/.vim/indent/
"
" Maintainer: IGREQUE IGREQUE
"
" Note:
"  This script requires IndentAnything version 1.2.2 or above.
"  See http://www.vim.org/scripts/script.php?script_id=1839
"
" Thanks: Tye Zdrojewski, the creater of IndentAnything.
"
" History:
"  2009.8.17: First release.
"  2009.8.17: Corrected a simple mistake and make one of b:indentTrios better.
"  2009.8.18: Fixed a bug that it indents by mistake after you type a line like "asif=1"
"  2009.8.19: Fixed a bug which happens when you use a statement modifier.
"  2009.11.21: Removed '*' and '/' from b:lineContList. Because '/' causes a mis-indent when using a Regexp literal.
"
" Known Bugs:
"* doesn't work well when you type such a line like below.
"  if foo == "foo" then puts "Yes" else puts "*Not end*" end #Only if the line *starts with* "if" etc.
"
"* In a block( starts with a word, like 'if', 'when', 'do' etc. ), reindents by mistake when you type 
"  an identifier which starts with "els", "when", "rescue", and "ensure" at the beginning of a line.
"  Example.
"  if a > 1
"    when_to_go = Time.new #Reindent by mistake here.
"  end

"2009.8.17: This switch must be on. But I forgot.
let IndentAnything_Dbg = 1

" Only load this indent file when no other was loaded.
if exists("b:did_indent") && ! IndentAnything_Dbg
  finish
endif

let b:did_indent = 1

setlocal indentexpr=IndentAnything()
setlocal indentkeys+=0),0},0],0=end,0=els,0=when,0=rescue,0=ensure

" Only define the function once.
if exists("*IndentAnything") && ! IndentAnything_Dbg
  finish
endif

setlocal indentexpr=IndentAnything()

""" BEGIN IndentAnything specification

"
" Syntax name REs for comments and strings. 
" But these REs are perfect for avoiding matching of pairs.
" And I'm sorry I don't know how to test this part.
"
let b:commentRE      = 'rubyComment'
"let b:lineCommentRE  = 'javaScriptLineComment'
"let b:blockCommentRE = 'javaScriptComment'
let b:stringRE            = 'rubyString'
"let b:singleQuoteStringRE = 'javaScriptStringS'
"let b:doubleQuoteStringRE = 'javaScriptStringD'


"Special statement(class def do if...) and parenthesis.
"2009.08.19: Divided keywords into two groups:
"  "usually used at the beginning of the line of the block( module, class, def, if, unless, while, until, case, and for )"
"  and not so.
let b:indentTrios = [
  \ [
    \'\(^\s*module\|^\s*class\|^\s*def\|\<do\|^\s*if\|^\s*unless\|^\s*while\|^\s*until\|^\s*for\|^\s*case\|^\s*begin\)\>\([^#]*\(\<end\>\)\)\@!',
    \'\<\(els\|when\|rescue\|ensure\)',
    \'end'
  \ ],
  \ [ '(', '', ')' ],
  \ [ '{', '', '}' ],
  \ [ '\[', '', '\]' ],
\]

"
" Line continuations.  Lines that are continued on the next line are
" if/unless/for/while/until statements that are NOT followed by a '{' block and operators
" at the end of a line.
"

"Operators which don't have the right-hand-side, and a backslash in the end of a statement.
"You might want more operators in this regexp.
let b:lineContList = [
	\ { 'pattern' : '\(+\|-\|=\|+=\|\*=\|/=\|-=\|\\\)\s*\(#.*\)\?$' },
\]

"
" If a continued line and its continuation can have line-comments between them, then this should be true.
"
let b:contTraversesLineComments = 1
