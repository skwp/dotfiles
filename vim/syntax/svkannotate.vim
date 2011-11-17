" Vim syntax file
" Language:	SVK annotate output
" Maintainer:	Bob Hiestand <bob.hiestand@gmail.com>
" Remark:	Used by the vcscommand plugin.
" License:
" Copyright (c) 2007 Bob Hiestand
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

syn match svkDate /\d\{4}-\d\{1,2}-\d\{1,2}/ skipwhite contained
syn match svkName /(\s*\zs\S\+/ contained nextgroup=svkDate skipwhite
syn match svkVer /^\s*\d\+/ contained nextgroup=svkName skipwhite
syn region svkHead start=/^/ end="):" contains=svkVer,svkName,svkDate oneline

if !exists("did_svkannotate_syntax_inits")
	let did_svkannotate_syntax_inits = 1
	hi link svkName Type
	hi link svkDate Comment
	hi link svkVer Statement
endif

let b:current_syntax="svkAnnotate"
