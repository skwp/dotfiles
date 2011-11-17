" Vim syntax file
" Language:	HG annotate output
" Maintainer:	Bob Hiestand <bob.hiestand@gmail.com>
" Remark:	Used by the vcscommand plugin.
" License:
" Copyright (c) 2010 Bob Hiestand
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

syn match hgVer /\d\+/ contained
syn match hgName /^\s*\S\+/ contained
syn match hgHead /^\s*\S\+\s\+\d\+:/ contains=hgVer,hgName

if !exists("did_hgannotate_syntax_inits")
	let did_hgannotate_syntax_inits = 1
	hi link hgName Type
	hi link hgVer Statement
endif

let b:current_syntax="hgAnnotate"
