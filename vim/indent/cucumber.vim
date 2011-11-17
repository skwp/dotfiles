" Vim indent file
" Language:	Cucumber
" Maintainer:	Tim Pope <vimNOSPAM@tpope.info>

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal autoindent
setlocal indentexpr=GetCucumberIndent()
setlocal indentkeys=o,O,*<Return>,<:>,0<Bar>,0#,=,!^F

" Only define the function once.
if exists("*GetCucumberIndent")
  finish
endif

function! GetCucumberIndent()
  let line  = getline(prevnonblank(v:lnum-1))
  let cline = getline(v:lnum)
  if cline =~# '^\s*\%(Background\|Scenario\|Scenario Outline\):'
    return &sw
  elseif cline =~# '^\s*\%(Examples\|Scenarios\):'
    return 2 * &sw
  elseif line =~# '^\s*\%(Background\|Scenario\|Scenario Outline\):'
    return 2 * &sw
  elseif line =~# '^\s*\%(Examples\|Scenarios\):'
    return 3 * &sw
  elseif cline =~# '^\s*|' && line =~# '^\s*|'
    return indent(prevnonblank(v:lnum-1))
  elseif cline =~# '^\s*|' && line =~# '^\s*[^|#]'
    return indent(prevnonblank(v:lnum-1)) + &sw
  elseif cline =~# '^\s*[^|#]' && line =~# '^\s*|'
    return indent(prevnonblank(v:lnum-1)) - &sw
  endif
  return -1
endfunction

" vim:set sts=2 sw=2:
