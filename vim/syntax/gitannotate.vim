" Vim syntax file
" Language:	git annotate output
" Maintainer:	Bob Hiestand <bob.hiestand@gmail.com>
" Remark:	Used by the vcscommand plugin.
" License:
" Copyright (c) 2009 Bob Hiestand
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.

if exists("b:current_syntax")
	finish
endif

syn region gitName start="(\@<=" end="\( \d\d\d\d-\)\@=" contained
syn match gitCommit /^\^\?\x\+/ contained
syn match gitDate /\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d [+-]\d\d\d\d/ contained
syn match gitLineNumber /\d\+)\@=/ contained
syn region gitAnnotation start="^" end=") " oneline keepend contains=gitCommit,gitLineNumber,gitDate,gitName

if !exists("did_gitannotate_syntax_inits")
	let did_gitannotate_syntax_inits = 1
	hi link gitName Type
	hi link gitCommit Statement
	hi link gitDate Comment
	hi link gitLineNumber Label
endif

let b:current_syntax="gitAnnotate"
