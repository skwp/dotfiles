" Does not work on pending 'blocks', only single lines
"
" Given:
" it "foo bar" do
"   pending("bla bla"
"
" Produce:
" xit "foo bar" do
"
function! ChangePendingRspecToXit()
  " Find the next occurrence of pending
  while(search("pending(") > 0)
    " Delete it
    normal dd
    " Search backwards to the it block
    ?it\s
    " add an 'x' to the 'it' to make it 'xit'
    normal ix
  endwhile
endfunction

nnoremap <silent> ,rxit :call ChangePendingRspecToXit()<cr>

" insert a before { } block around a line
nnoremap <silent> \bf ^ibefore { <esc>$a }

" insert a specify { } block around a line
nnoremap <silent> \sp ^ispecify { <esc>$a }

