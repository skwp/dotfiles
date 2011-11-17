" FILE:     plugin/conque_term.vim {{{
" AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
" WEBSITE:  http://conque.googlecode.com
" MODIFIED: 2011-09-02
" VERSION:  2.3, for Vim 7.0
" LICENSE:
" Conque - Vim terminal/console emulator
" Copyright (C) 2009-2011 Nico Raffo 
"
" MIT License
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
" }}}

" See docs/conque_term.txt for help or type :help ConqueTerm

if exists('g:ConqueTerm_Loaded') || v:version < 700
    finish
endif

" **********************************************************************************************************
" **** DEFAULT CONFIGURATION *******************************************************************************
" **********************************************************************************************************

" DO NOT EDIT CONFIGURATION SETTINGS IN THIS FILE!
" Define these variables in your local .vimrc to over-ride the default values

" {{{

" Fast mode {{{
" Disables all features which could cause Conque to run slowly, including:
"   * Disables terminal colors
"   * Disables some multi-byte character handling
if !exists('g:ConqueTerm_FastMode')
    let g:ConqueTerm_FastMode = 0
endif " }}}

" automatically go into insert mode when entering buffer {{{
if !exists('g:ConqueTerm_InsertOnEnter')
    let g:ConqueTerm_InsertOnEnter = 0
endif " }}}

" Allow user to use <C-w> keys to switch window in insert mode. {{{
if !exists('g:ConqueTerm_CWInsert')
    let g:ConqueTerm_CWInsert = 0
endif " }}}

" Choose key mapping to leave insert mode {{{
" If you choose something other than '<Esc>', then <Esc> will be sent to terminal
" Using a different key will usually fix Alt/Meta key issues
if !exists('g:ConqueTerm_EscKey')
    let g:ConqueTerm_EscKey = '<Esc>'
endif " }}}

" Use this key to execute the current file in a split window. {{{
" THIS IS A GLOBAL KEY MAPPING
if !exists('g:ConqueTerm_ExecFileKey')
    let g:ConqueTerm_ExecFileKey = '<F11>'
endif " }}}

" Use this key to send the current file contents to conque. {{{
" THIS IS A GLOBAL KEY MAPPING
if !exists('g:ConqueTerm_SendFileKey')
    let g:ConqueTerm_SendFileKey = '<F10>'
endif " }}}

" Use this key to send selected text to conque. {{{
" THIS IS A GLOBAL KEY MAPPING
if !exists('g:ConqueTerm_SendVisKey')
    let g:ConqueTerm_SendVisKey = '<F9>'
endif " }}}

" Use this key to toggle terminal key mappings. {{{
" Only mapped inside of Conque buffers.
if !exists('g:ConqueTerm_ToggleKey')
    let g:ConqueTerm_ToggleKey = '<F8>'
endif " }}}

" Enable color. {{{
" If your apps use a lot of color it will slow down the shell.
" 0 - no terminal colors. You still will see Vim syntax highlighting.
" 1 - limited terminal colors (recommended). Past terminal color history cleared regularly.
" 2 - all terminal colors. Terminal color history never cleared.
if !exists('g:ConqueTerm_Color')
    let g:ConqueTerm_Color = 1
endif " }}}

" Color mode. Windows ONLY {{{
" Set this variable to 'conceal' to use Vim's conceal mode for terminal colors.
" This makes colors render much faster, but has some odd baggage.
if !exists('g:ConqueTerm_ColorMode')
    let g:ConqueTerm_ColorMode = ''
endif " }}}

" TERM environment setting {{{
if !exists('g:ConqueTerm_TERM')
    let g:ConqueTerm_TERM =  'vt100'
endif " }}}

" Syntax for your buffer {{{
if !exists('g:ConqueTerm_Syntax')
    let g:ConqueTerm_Syntax = 'conque_term'
endif " }}}

" Keep on updating the shell window after you've switched to another buffer {{{
if !exists('g:ConqueTerm_ReadUnfocused')
    let g:ConqueTerm_ReadUnfocused = 0
endif " }}}

" Use this regular expression to highlight prompt {{{
if !exists('g:ConqueTerm_PromptRegex')
    let g:ConqueTerm_PromptRegex = '^\w\+@[0-9A-Za-z_.-]\+:[0-9A-Za-z_./\~,:-]\+\$'
endif " }}}

" Choose which Python version to attempt to load first {{{
" Valid values are 2, 3 or 0 (no preference)
if !exists('g:ConqueTerm_PyVersion')
    let g:ConqueTerm_PyVersion = 2
endif " }}}

" Path to python.exe. (Windows only) {{{
" By default, Conque will check C:\PythonNN\python.exe then will search system path
" If you have installed Python in an unusual location and it's not in your path, fill in the full path below
" E.g. 'C:\Program Files\Python\Python27\python.exe'
if !exists('g:ConqueTerm_PyExe')
    let g:ConqueTerm_PyExe = ''
endif " }}}

" Automatically close buffer when program exits {{{
if !exists('g:ConqueTerm_CloseOnEnd')
    let g:ConqueTerm_CloseOnEnd = 0
endif " }}}

" Send function key presses to terminal {{{
if !exists('g:ConqueTerm_SendFunctionKeys')
    let g:ConqueTerm_SendFunctionKeys = 0
endif " }}}

" Session support {{{
if !exists('g:ConqueTerm_SessionSupport')
    let g:ConqueTerm_SessionSupport = 0
endif " }}}

" hide Conque startup messages {{{
" messages should only appear the first 3 times you start Vim with a new version of Conque
" and include important Conque feature and option descriptions
" TODO - disabled and unused for now
if !exists('g:ConqueTerm_StartMessages')
    let g:ConqueTerm_StartMessages = 1
endif " }}}

" Windows character code page {{{
" Leave at 0 to use current environment code page.
" Use 65001 for utf-8, although many console apps do not support it.
if !exists('g:ConqueTerm_CodePage')
    let g:ConqueTerm_CodePage = 0
endif " }}}

" InsertCharPre support {{{
" Disable this feature by default, still in Beta
if !exists('g:ConqueTerm_InsertCharPre')
    let g:ConqueTerm_InsertCharPre = 0
endif " }}}

" }}}

" **********************************************************************************************************
" **** Startup *********************************************************************************************
" **********************************************************************************************************

" Startup {{{

let g:ConqueTerm_Loaded = 1
let g:ConqueTerm_Idx = 0
let g:ConqueTerm_Version = 230

command! -nargs=+ -complete=shellcmd ConqueTerm call conque_term#open(<q-args>)
command! -nargs=+ -complete=shellcmd ConqueTermSplit call conque_term#open(<q-args>, ['belowright split'])
command! -nargs=+ -complete=shellcmd ConqueTermVSplit call conque_term#open(<q-args>, ['belowright vsplit'])
command! -nargs=+ -complete=shellcmd ConqueTermTab call conque_term#open(<q-args>, ['tabnew'])

" }}}

" **********************************************************************************************************
" **** Global Mappings & Autocommands **********************************************************************
" **********************************************************************************************************

" Startup {{{

if exists('g:ConqueTerm_SessionSupport') && g:ConqueTerm_SessionSupport == 1
    autocmd SessionLoadPost * call conque_term#resume_session()
endif

if maparg(g:ConqueTerm_ExecFileKey, 'n') == ''
    exe 'nnoremap <silent> ' . g:ConqueTerm_ExecFileKey . ' :call conque_term#exec_file()<CR>'
endif

" }}}

" vim:foldmethod=marker
