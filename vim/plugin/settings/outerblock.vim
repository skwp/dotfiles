" Navigate to the block surrounding this one
" For example if you're inside
" foo do
"    bar do
"      # you are here
"    end
" end
"
" Then hitting ,orb ("outer ruby block") will take you to 'foo do'
"
" This is relying on the textobj-rubyblock which gives us 'ar' around ruby
" and matchit.vim which gives us jumping to the matching 
nnoremap <silent> ,orb :normal varar%<esc><esc>
