" Open the Ag command and place the cursor into the quotes
nmap ,ag :Ag ""<Left>
nmap ,af :AgFile ""<Left>

" Ignore tags, .tags
if split(system("ag --version"), "[ \n\r\t]")[2] =~ '\d\+.\(\(2[5-9]\)\|\([3-9][0-9]\)\)\(.\d\+\)\?'
  let g:ag_prg="ag --vimgrep"
else
  " --noheading seems odd here, but see https://github.com/ggreer/the_silver_searcher/issues/361
  let g:ag_prg="ag --column --nogroup --noheading --ignore tags --ignore .tags"
endif
