"
" Copyright 2006 Tye Zdrojewski 
"
" Licensed under the Apache License, Version 2.0 (the "License"); you may not
" use this file except in compliance with the License. You may obtain a copy of
" the License at
" 
" 	http://www.apache.org/licenses/LICENSE-2.0
" 
" Unless required by applicable law or agreed to in writing, software distributed
" under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
" CONDITIONS OF ANY KIND, either express or implied. See the License for the
" specific language governing permissions and limitations under the License.
"
"
"
" Plugin:
"
"   Indent Anything
"
" Version: 1.2.2
"
" Description:
"
"   This is an indentation script that calculates the indent level based
"   on begin/end syntax pairs and line-continuation patterns.  It allows one
"   to create an indent script without writing any code, taking it's
"   instruction from configurable values.
"
"   Included with this script is Javascript indentation, an example that
"   explains the configurable values.
"
"
" Installation:
"
"   Place this file in your home directory under ~/.vim/indent/, or replace
"   the system indent/javascript.vim file to affect all users.
"
" Maintainer: Tye Z. <zdro@yahoo.com>
"
" Customization:
"
"   The only thing that can really be customized at this point is whether or
"   not a line is echoed explaining the indentation result.  To turn this on,
"   set the following variable like so:
"
"       let b:indent_anything_echo = 1
"
"
" History:
"
"   1.2 - made some functions script-local to prevent naming collisions
"       - fixed some broken indentation in the middle of a block comment,
"         which showed up in Javascript indentation.
"
"   1.2.2 - Fixed a bug causing the line after a single-line block comment to
"           always have an indent of '0' (i.e. the line after /* comment */).
"         - Added Apache 2 license
"
"

let s:supportedVimVersion = 700

if version < s:supportedVimVersion
    echoerr "IndentAnything only supported for Vim " . s:supportedVimVersion . " and up."
    finish
endif


"
" Initialize everything needed by this script.  Only set those values that are
" not set already.
"
function! IndentAnythingInit()
    let b:IndentAnythingInitialized = 1
    " Start with a regular expression that will never match.  Matching
    " will influence behavior, which the defaults should not do.
    let s:nonMatcher = '[x]\&[^x]'
    if !exists('b:commentRE')
        let b:commentRE      = s:nonMatcher
    endif
    if !exists('b:lineCommentRE')
        let b:lineCommentRE  = s:nonMatcher
    endif
    if !exists('b:blockCommentRE')
        let b:blockCommentRE = s:nonMatcher
    endif
    if !exists('b:stringRE')
        let b:stringRE            = s:nonMatcher
    endif
    if !exists('b:singleQuoteStringRE')
        let b:singleQuoteStringRE = s:nonMatcher
    endif
    if !exists('b:doubleQuoteStringRE')
        let b:doubleQuoteStringRE = s:nonMatcher
    endif

    if !exists('b:blockCommentStartRE')
        let b:blockCommentStartRE  = s:nonMatcher
    endif
    if !exists('b:blockCommentMiddleRE')
        let b:blockCommentMiddleRE = s:nonMatcher
    endif
    if !exists('b:blockCommentEndRE')
        let b:blockCommentEndRE    = s:nonMatcher
    endif
    if !exists('b:blockCommentMiddleExtra')
        let b:blockCommentMiddleExtra = 0
    endif

    if !exists('b:indentTrios')
        let b:indentTrios = []
    endif
    if !exists('b:lineContList')
        let b:lineContList = []
    endif

    if !exists('b:contTraversesLineComments')
        let b:contTraversesLineComments = 1
    endif

    if !exists('b:indent_anything_echo')
        let b:indent_anything_echo = 0
    endif
endfunction

function! SynHere()
    return synIDattr(synID(line('.'), col('.'), 1), "name")
endfunction
"
" Returns true if the cursor is currently inside a comment or a string
"
function! InCommentOrString()
    let syn = synIDattr(synID(line("."), col("."), 1), "name")
    if syn =~ b:commentRE || syn =~ b:stringRE
        return 1
    endif
    return 0
endfunction

"
" Returns true if the given line is a comment line (b:lineCommentRE)
"
function! IsLineComment(linenum)
    let cursor = getpos('.')
    exec a:linenum
    normal ^
    let l:iscomment = 0
    let l:syn = synIDattr(synID(line('.'), col('.'), 1), "name")
    if l:syn =~ b:lineCommentRE " b:commentRE || l:syn =~ b:stringRE
        let l:iscomment = 1
    endif
    call setpos('.', cursor)
    return l:iscomment
endfunction

"
" Returns true if the given line is a comment line (b:lineCommentRE)
"
function! IsComment(linenum)
    let cursor = getpos('.')
    exec a:linenum
    normal ^
    let l:iscomment = 0
    let l:syn = synIDattr(synID(line('.'), col('.'), 1), "name")
    if l:syn =~ b:commentRE " b:commentRE || l:syn =~ b:stringRE
        let l:iscomment = 1
    endif
    call setpos('.', cursor)
    return l:iscomment
endfunction

"
" Returns true if the given line is a comment line (b:lineCommentRE)
"
function! IsBlockComment(linenum)
    let cursor = getpos('.')
    exec a:linenum
    normal ^
    let l:iscomment = 0
    let l:syn = synIDattr(synID(line('.'), col('.'), 1), "name")
    if l:syn =~ b:blockCommentRE " b:commentRE || l:syn =~ b:stringRE
        let l:iscomment = 1
    endif
    call setpos('.', cursor)
    return l:iscomment
endfunction

"
" Get the first line at or on the given line that is not blank and is not a
" comment line.
"
function! GetPrevNonBlankNonComment(begin)
    let cursor = getpos('.')

    let l:prevbegin = a:begin
    while 1
        let l:lnum = prevnonblank(l:prevbegin)
        if l:lnum == 0
            return 0
        endif

        "if IsLineComment(l:lnum)
        if IsComment(l:lnum)
            let l:prevbegin -= 1
            continue
        endif

        break
    endwhile

    " Restore original cursor location
    call setpos('.', cursor)
    return l:lnum
endfunction

"
" This does all the work.  Does indentation for:
"
"       - All pairs defined in b:indentTrios
"       - All line continuations in b:lineContList
"       - Block comments
"
function! IndentAnything()

    if !exists('b:IndentAnythingInitialized')
        call IndentAnythingInit()
    endif

    let adj = 0  " Adjustment

    let g:lastindent = ""
    let b:hardindent = -1
    let currlnum = v:lnum
    let currlnum = line('.')
    let currline = getline(currlnum)
    let lastline = ''
    let prevline = ''

    " Find non-blank lines above the current line.
    let lastlnum = prevnonblank(currlnum - 1)
    let prevlnum = prevnonblank(lastlnum - 1)
    if lastlnum != 0 
        let lastline = getline(lastlnum)
    endif
    if prevlnum != 0
        let prevline = getline(prevlnum)
    endif
    if b:contTraversesLineComments
        let lastcodelnum = GetPrevNonBlankNonComment(currlnum - 1)
        let prevcodelnum = GetPrevNonBlankNonComment(lastcodelnum - 1)
        if lastcodelnum !=0 
            let lastcodeline = getline(lastcodelnum)
        endif
    endif

    " Start from the first char on the line.  Vim doesn't seem to consistently
    " place the cursor there before calling the indent routines.
    call cursor(0, 1)
    call search('\S', 'W')

    let l:cur = getpos('.')

    "
    " Call indentation adjustment functions.
    "

    "
    " Block comments
    "
    let l:BlockCommentAdj = 0
    let l:BlockCommentAdj += s:GetBlockCommentIndent(currlnum, lastlnum)
    let adj += l:BlockCommentAdj

    "
    " Pairs
    "
    let b:lastclosed = { 'at' : 0 }
    let b:pairadj = 0
    if !l:BlockCommentAdj
        " If we're not in the middle of a block comment (because we haven't
        " made any adjustments for that), then process block indentation.
        for trio in b:indentTrios
            let b:pairadj += s:GetPairIndent(currline, lastline, lastlnum, 
                        \ trio[0], trio[1], trio[2])
        endfor
    endif
    let adj += b:pairadj

    "
    " Line continuations
    "
    let contadj = 0
    let isBlockCommentStart = currline =~ '^\s*' . b:blockCommentStartRE
    let isBlockCommentMid = (IsBlockComment(currlnum) && !isBlockCommentStart)
    if !isBlockCommentMid
        " If the current line is not the middle of a block comment, then
        " process line continuations.
        for ContRule in b:lineContList
            if b:contTraversesLineComments "&& !isBlockCommentStart
                let contadj = s:GetContIndent(ContRule, currline, lastcodeline, lastcodelnum, prevcodelnum)
            else
                let contadj = s:GetContIndent(ContRule, currline, lastline, lastlnum, prevlnum)
            endif
            " This is for line continuation patterns, of which there can be only
            " one per line to indicate continuation
            if contadj
                break
            endif
        endfor
        let adj += contadj
    endif


    "
    " Find the previous indent to which we will add the adjustment
    "
    let prevind = indent(lastlnum)

    if l:BlockCommentAdj
        let g:lastindent .= " indent (prevblockcomment: " . prevind . " at " . lastcodelnum . ") "
    elseif contadj && b:contTraversesLineComments
        " If we have adjusted for line continuation, then use the indentation
        " for the previous code line
        let prevind = indent(lastcodelnum)
        let g:lastindent .= " indent (prevcode: " . prevind . " at " . lastcodelnum . ") "

    elseif (isBlockCommentStart || !IsBlockComment(currlnum)) && IsBlockComment(lastlnum)
        " If this is the first line after a block comment, then add the
        " adjustment to the line where the block comment started.
        let prevind = s:GetPostBlockCommentIndent(lastlnum)
        let g:lastindent .= " indent (prevblock: " . prevind . " at " . lastlnum . ") "

    elseif exists("b:defaultIndentExpr")
        let g:lastindent .= " using defaultIndentExpr (" . b:defaultIndentExpr . ") "
        exec "let prevind = " . b:defaultIndentExpr
    else
        " Default to adjusting the previous line's indent.
        let g:lastindent .= " indent (prev: " . prevind . " at " . lastlnum . ") "
    endif

    " Just in case there is no previous indent.
    let prevind = (prevind == -1 ? 0 : prevind)

    if b:indent_anything_echo
        echom g:lastindent
    endif

    call setpos('.', l:cur)

    return adj + prevind

endfunction

"
" Get the adjustment for the second line of a block comment.  The second line
" will be aligned under the start of the block, even if it is not at the
" beginning of the line.  Extra adjustment (b:blockCommentMiddleExtra) will
" be added.
"
function! s:GetBlockCommentIndent(CurrLNum, LastLNum)
    let l:cursor = getpos('.')
    let l:adj = 0
    if a:LastLNum == searchpair(b:blockCommentStartRE, '', b:blockCommentEndRE, 'bWr')
                \ && a:LastLNum > 0
        let l:adj = col('.') + b:blockCommentMiddleExtra
        normal ^
        let l:adj -= col('.')
    endif
    call setpos('.', l:cursor)
    return l:adj
endfunction

function! s:GetPostBlockCommentIndent(LastLNum)

    let l:cursor = getpos('.')
    let l:ind = 0
    let l:comment_start_lnum = 0;

    " Find beginning of block comment containing the start of line LastLNum
    exec a:LastLNum
    normal ^
    let l:comment_start_lnum = searchpair(
                \ b:blockCommentStartRE, b:blockCommentMiddleRE, b:blockCommentEndRE, 'bWr')

    " Assume that the LastLNum is a block comment.  If the comment both
    " started and stopped on LastLNum, then searchpair will return 0.  In that
    " case, we just want to return the indent of LastLNum itself.
    if 0 == l:comment_start_lnum
        let l:comment_start_lnum = a:LastLNum
    endif

    let l:ind = indent(l:comment_start_lnum)

    if 1 || l:ind != 0 && b:indent_anything_echo 
        let g:lastindent = g:lastindent . 
                    \ "GetPostBlockCommentIndent: " . l:ind
    endif

    call setpos('.', l:cursor)

    "return l:ind
    return l:ind > 0 ? l:ind : 0

endfunction

"
" Get additional indentation based on blocks of code, as defined by the Head
" and Tail patterns.
"
function! s:GetPairIndent(CurrLine, LastLine, LastLNum, Head, Mid, Tail)

    let levels = 0
    let adj = 0
    let origcol = col(".")
    let origline = line(".")


    "
    " How many levels were started on the last line?  Search backwards for
    " pair starters until we're not on the last nonblank.  If the last line
    " doesn't contain the pair-starter, then don't bother with searchpair();
    " it's a performance bottleneck because (I think) it will always search
    " all the way back until it finds a match or can't search any more.
    "
    "
    if a:LastLine =~ a:Head
        while 1
            "
            " Include the limit of the search to be the last line.  BIG
            " performance booster!  That also means we only have to see *if*
            " there was a match, and not worry about where it is.
            "
            "let pairstart = searchpair(a:Head, a:Mid, a:Tail, 'Wb')
            "if pairstart == 0 || pairstart != a:LastLNum
            let pairstart = searchpair(a:Head, a:Mid, a:Tail, 'Wb', '', a:LastLNum)
            if pairstart == 0 "|| pairstart != a:LastLNum
                break
            endif
            let syn = synIDattr(synID(line("."), col("."), 1), "name")
            " Also continue on the off chance that we find the match on the
            " current line.  This shouldn't happen, but the pattern might
            " start with whitespace.
            if syn =~ b:commentRE || syn =~ b:stringRE || pairstart == origline
                continue
            endif
            let levels += 1
        endwhile
    endif

    " If we aren't within a level that was started on the last line, then
    " check how many levels were closed on the last line.
    "
    if levels == 0

        " Move to the beginning of the last line
        call cursor(a:LastLNum,0)
        normal ^

        " If the line starts with an open, The close shouldn't be counted as
        " such, because we're looking for closes that didn't start on this
        " line.
        if a:LastLine =~ '^\s*' . a:Head || 
                    \ (a:Mid != '' && a:LastLine =~ '^\s*' . a:Mid)
            let levels = 1
        endif

        "
        " Count the closes on the last line (i.e. LastLNum), stopping once
        " we've hit comments.  If the line doesn't even contain the end of the
        " pair, don't bother with searchpair() (same aforementioned
        " rationale).
        "
        if a:LastLine =~ a:Tail
            while 1
                "
                " Include the limit of the search to be the last line.  BIG
                " performance booster!  That also means we only have to see
                " *if* there was a match, and not worry about where it is.
                "
                "let pairend = searchpair(a:Head, a:Mid, a:Tail, 'W')
                "if pairend == 0 || a:LastLNum != pairend 
                "let pairend = searchpair(a:Head, a:Mid, a:Tail, 'W', '', a:LastLNum)
                let pairend = searchpair(a:Head, a:Mid, a:Tail, 'W',
                            \'InCommentOrString()', a:LastLNum)
                if pairend == 0 "|| a:LastLNum != pairend 

                    " STARTS with a:Tail, since we already know the line
                    " matches it.
                    if b:lastclosed.at < col('.') && (
                                \ a:LastLine =~ '^\s*' . a:Tail 
                                \ || (a:Mid != '' && a:LastLine =~ '^\s*' . a:Mid) )
                        let b:lastclosed = { 
                                    \ 'at' : col('.'), 
                                    \ 'head' : a:Head,
                                    \ 'mid' : a:Mid,
                                    \ 'tail' : a:Tail }
                    endif


                    break
                endif
                " This might not be needed with the expr included in the
                " search call.
                "let syn = synIDattr(synID(line("."), col("."), 1), "name")
                "if syn =~ b:commentRE || syn =~ b:stringRE || syn == ''
                "    break
                "endif
                let levels -= 1

                " Track the last close to try to match pairs that start on
                " line continuations
                if b:lastclosed.at < col('.')
                    let b:lastclosed = { 
                                \ 'at'   : col('.'), 
                                \ 'head' : a:Head,
                                \ 'mid'  : a:Mid,
                                \ 'tail' : a:Tail }
                endif
            endwhile
        endif
    endif

    " This is redundant, as per above
    " If the current line starts with a close, count it.  It won't effect the
    " indentation of the next line because it is the first thing on the line
    " and won't be counted as a "close on the last line".
    if a:CurrLine =~ '^\s*' . a:Tail 
                \ || (a:Mid != '' && a:CurrLine =~ '^\s*' . a:Mid)
        let levels -= 1
    endif

    " Restore original cursor location
    call cursor(origline, origcol)

    let adj = &sw*levels
    if adj != 0 && b:indent_anything_echo
        let g:lastindent = g:lastindent . 
                    \ "GetPairIndent(" . a:Head . "/" . b:lastclosed.at . "):" . adj . " "
    endif

    return adj

endfunction


function! s:GetContIndent(Rule, CurrLine, LastLine, LastLNum, PrevLNum)

    let adj = 0
    let origcol = col(".")
    let origline = line(".")
    let lastcont = 0
    let prevcont = 0

    let l:lastlnum = a:LastLNum
    let l:prevlnum = a:PrevLNum

    let l:preblockstart = -1

    " Get the last matching line number.  If the match occurs w/in a comment
    " or string, then it's a non-match.
    "
    "let lastmatchlnum = search(a:Rule.pattern, 'Wb', a:PrevLNum)
    let lastmatchlnum = search(a:Rule.pattern, 'Wb', a:LastLNum)
    let syn = synIDattr(synID(line("."), col("."), 1), "name")

    "if syn =~ b:commentRE || syn =~ b:stringRE
    if syn =~ b:commentRE || syn =~ b:stringRE || b:lastclosed.at > 0
        let lastmatchlnum = 0
    endif

    " Should be able to just search to the line....
    " " Figure out the last and previous continuation status
    " if lastmatchlnum && lastmatchlnum == a:LastLNum 
    "     let lastcont = 1
    " endif
    if lastmatchlnum == a:LastLNum
        let lastcont = 1
    endif

    " start checking at the start of the block that ended on the prev line
    if b:lastclosed.at > 0
        call cursor(a:LastLNum, b:lastclosed.at)
        " TODO: add 'skip' to skip comments
        let l:preblockstart = searchpair(b:lastclosed.head, b:lastclosed.mid, b:lastclosed.tail, 'bW')
        let g:lastindent .= ' postpair ("' . b:lastclosed.head . '"): '
                    \ . l:preblockstart . '/' . col('.') . ' '

        if b:contTraversesLineComments
            let l:prevlnum = GetPrevNonBlankNonComment(line('.') - 1)
        else
            let l:prevlnum = prevnonblank(line('.') - 1)
        endif
    endif


    " Get the previous matching line number.  If the match occurs w/in a
    " comment or string, then it's a non-match.  Use the adjusted, local
    " prevlnum as the limit of the search, since we don't care about matches
    " beyond that.
    let prevmatchlnum = search(a:Rule.pattern, 'Wb', l:prevlnum)


    let syn = synIDattr(synID(line("."), col("."), 1), "name")
    " Handle:
    "  if ()
    "    if () {
    "      this_line; // should not be reduced
    "if syn =~ b:commentRE || syn =~ b:stringRE
    if syn =~ b:commentRE || syn =~ b:stringRE
        let prevmatchlnum = 0
    endif

    " Should be able to just search to the line....
    " if ( lastmatchlnum && lastmatchlnum == a:PrevLNum ) 
    "             \ || ( prevmatchlnum && prevmatchlnum == l:prevlnum )
    "     let prevcont = 1
    " endif
    "
    " If there is a previous line, it is a continued line, and we haven't
    " already done a positive adjustment for a pair/block, then reduce.
    " Don't undo a positive adjustment for a pair because the previous line
    " was a continued line.  That will happen after the end of the block.
    "if prevmatchlnum == l:prevlnum && b:pairadj <= 0
    if l:prevlnum && prevmatchlnum == l:prevlnum && b:pairadj <= 0
        let prevcont = 1
    endif

    "echom "lastcont: " . lastcont . 
    "            \ ", prevcont: " . prevcont . 
    "            \ ", lastmatchlnum: " . lastmatchlnum .
    "            \ ", prevmatchlnum: " . prevmatchlnum .
    "            \ ", lastlnum: " . a:LastLNum . 
    "            \ ", PrevLNum: " . a:PrevLNum
    let firstcont = (lastcont && !prevcont)
    let firstcont = ((lastcont && !prevcont) || (lastcont && b:pairadj))

    " If we are adjusting the current line for a pair, then don't count this
    " line as a post-continuation line.  The post continuation line will be
    " after the close of said pair.
    let postcont  = (!lastcont && prevcont)
    "let postcont  = (!lastcont && prevcont && !b:pairadj )

    let g:lastindent .= 'lastcont (' . lastcont . '), prevcont (' . prevcont . ') '


    "if firstcont && a:CurrLine !~ '^\s*{'
    if firstcont 
        if has_key(a:Rule, 'ignore') && a:CurrLine =~ a:Rule.ignore
            let g:lastindent .= "(ignoring '" . a:Rule.ignore . "') "
        else
            let adj = adj + &sw
        endif
        "elseif postcont && a:LastLine !~ '^\s*{' "&& !b:pairadj
    elseif postcont 
        if has_key(a:Rule, 'ignore') && a:LastLine =~ a:Rule.ignore
            let g:lastindent .= "(ignoring '" . a:Rule.ignore . "') "
        else
            let adj = adj - &sw
        endif
    endif

    call cursor(origline, origcol)

    if adj != 0 && b:indent_anything_echo
        let g:lastindent = g:lastindent . 
                    \ "GetContIndent('" . a:Rule.pattern . "'):" . adj . " "
    endif
    return adj

endfunction




