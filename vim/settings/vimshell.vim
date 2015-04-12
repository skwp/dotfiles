
"let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
"let g:vimshell_right_prompt = 'gita#statusline#format("%{|/}ln%lb%{ <> |}rn%{/|}rb")'
let g:vimshell_editor_command = 'mvim'

let g:vimshell_prompt = '% '
"let g:vimshell_environment_term = 'xterm'
let g:vimshell_split_command = ''
let g:vimshell_enable_transient_user_prompt = 1
let g:vimshell_force_overwrite_statusline = 1

 "let g:vimshell_prompt_expr = 'escape($USER . ":". fnamemodify(getcwd(), ":~"), "\\[]()?! ")."(". gita#statusline#format("%{|/}ln%lb").") % "'
let g:vimshell_prompt_expr ='escape(fnamemodify(getcwd(), ":~"), "\\[]()?! "). "(". gita#statusline#format("%lb %nu.%nm.%nc.%nd").") % "'
let g:vimshell_prompt_pattern = '^\%(\f\|\\.\)\+(\f\+) % '

