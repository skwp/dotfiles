" This remaps easymotion to show us only the left
" hand home row keys as navigation options which 
" may mean more typing to get to a particular spot
" but it'll all be isolated to one area of the keyboard
call EasyMotion#InitOptions({
\   'leader_key'      : '<Leader><Leader>'
\ , 'keys'            : 'fjdkslewio'
\ , 'do_shade'        : 1
\ , 'do_mapping'      : 1
\ , 'grouping'        : 1
\
\ , 'hl_group_target' : 'Question'
\ , 'hl_group_shade'  : 'EasyMotionShade'
\ })

" Use EasyMotion by double tapping comma
nmap <silent> ,, \\w
" Use EasyMotion backwards by z,,
nmap <silent> z,, \\b
" Make EasyMotion more yellow, less red
hi clear EasyMotionTarget
hi! EasyMotionTarget guifg=yellow
