" Git
autocmd BufNewFile,BufRead *.git/COMMIT_EDITMSG    set ft=gitcommit
autocmd BufNewFile,BufRead *.git/config,.gitconfig set ft=gitconfig
autocmd BufNewFile,BufRead git-rebase-todo         set ft=gitrebase
autocmd BufNewFile,BufRead .msg.[0-9]*
      \ if getline(1) =~ '^From.*# This line is ignored.$' |
      \   set ft=gitsendemail |
      \ endif
autocmd BufNewFile,BufRead *.git/**
      \ if getline(1) =~ '^\x\{40\}\>\|^ref: ' |
      \   set ft=git |
      \ endif

" This logic really belongs in scripts.vim
autocmd BufNewFile,BufRead,StdinReadPost *
      \ if getline(1) =~ '^\(commit\|tree\|object\) \x\{40\}$\|^tag \S\+$' |
      \   set ft=git |
      \ endif
