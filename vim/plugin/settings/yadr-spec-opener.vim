" Find the related spec for any file you open. Requires
"  * Your specs live in spec/ or fast_spec/
"  * Your pwd (current dir) is the project root
"  * You use the same dir structure in your code and specs so that
"    code living at lib/foo/bar.rb has a spec at spec/lib/foo/bar.rb
"
" This method handles files in fast_spec unlike the :A and :AV functions
" that ship with rails.vim
function! FindSpec()
  let s:fullpath = expand("%:p")
  let s:filepath = expand("%:h")
  let s:fname = expand("%:t")

  " Possible names for the spec/test for the file we're looking at
  let s:test_names = [substitute(s:fname, ".rb$", "_spec.rb", ""), substitute(s:fname, ".rb$", "_test.rb", "")]

  " Possible paths
  let s:test_paths = ["spec", "fast_spec", "test"]
  for test_name in s:test_names
    for path in s:test_paths
      let s:filepath_without_app = substitute(s:filepath, "app/", "", "")
      let s:spec_path = path . "/" . s:filepath_without_app . "/" . test_name
      let s:full_spec_path = substitute(s:fullpath, s:filepath . "/" . s:fname, s:spec_path, "")
      if filereadable(s:full_spec_path)
        execute ":botright vsp " . s:full_spec_path
        return
      endif
    endfor
  endfor
endfunction

nnoremap <C-s> :call FindSpec()<CR>
