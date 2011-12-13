"statusline setup
set statusline=%#DiffAdd#
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline=%#DiffAdd#
set statusline+=%f\  
set statusline+=%#LineNr# "switch to colors used for line number
set statusline+=%{fugitive#statusline()}
set statusline+=%#DiffAdd#  "switch back to normal
set statusline+=%=      "left/right separator
set statusline+=%m      "modified flag

"display a warning if &paste is set
set statusline+=%#DiffChange#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%#LineNr# "switch to colors used for line number
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%#DiffAdd# "switch to colors used for line number
set statusline+=%c:     "cursor column
set statusline+=%l/%L   "cursor line/total lines
"set statusline+=\ %P    "percent through file
set laststatus=2

"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction
