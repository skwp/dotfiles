"Use RipGrep for lightning fast Gsearch command
set grepprg=rg\ --vimgrep\ --no-heading
set grepformat=%f:%l:%c:%m,%f:%l:%m
let g:grep_cmd_opts = '--line-number'
