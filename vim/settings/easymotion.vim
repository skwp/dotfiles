" Use all letters and semicolon as navigation keys, as they are all in
" close proximity to the home row and therefore easy to type.
call EasyMotion#InitOptions({
\   'leader_key'      : '<Leader><Leader>'
\ , 'keys'            : 'asdghklqwertyuiopzxcvbnmfj;'
\ , 'do_shade'        : 1
\ , 'do_mapping'      : 1
\ , 'grouping'        : 1
\
\ , 'hl_group_target' : 'Type'
\ , 'hl_group_shade'  : 'Comment'
\ })

nmap ,<ESC> ,,w
nmap ,<S-ESC> ,,b
