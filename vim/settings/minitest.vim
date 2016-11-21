if !exists('g:test#ruby#minitest#file_pattern')
  let g:test#ruby#minitest#file_pattern = '_test\.rb$'
endif

function! test#ruby#minitest#test_file(file) abort
  return a:file =~# g:test#ruby#minitest#file_pattern
endfunction

function! test#ruby#minitest#build_position(type, position) abort
  if a:type == 'nearest'
    let name = s:nearest_test(a:position)
    "Fix test not found when supply class name
    let method_name = substitute(name, ".*#", "", "g")
    if !empty(name)
      return [a:position['file'], '--name', '/'.method_name.'/']
    else
      return [a:position['file']]
    endif
  elseif a:type == 'file'
    return [a:position['file']]
  else
    return []
  endif
endfunction

function! test#ruby#minitest#build_args(args) abort
  for idx in range(0, len(a:args) - 1)
    if test#base#file_exists(a:args[idx])
      let path = remove(a:args, idx) | break
    endif
  endfor

  if exists('path') && isdirectory(path)
    let path = fnamemodify(path, ':p:.') . '**/*_test.rb'
  elseif !exists('path')
    let path = 'test/**/*_test.rb'
  endif

  for option in ['--name', '--seed']
    let idx = index(a:args, option)
    if idx != -1
      let value = remove(a:args, idx + 1)
      let a:args[idx] = option.'='.shellescape(value, 1)
    endif
  endfor

  let kind = matchstr(test#base#executable('ruby#minitest'), 'ruby\|rake')
  return s:build_{kind}_args(get(l:, 'path'), a:args)
endfunction

function! s:build_rake_args(path, args) abort
  let cmd = []
  if !empty(a:path) | call add(cmd, 'TEST="'.escape(a:path, '"').'"') | endif
  if !empty(a:args) | call add(cmd, 'TESTOPTS="'.escape(join(a:args), '"`').'"') | endif

  return cmd
endfunction

function! s:build_ruby_args(path, args) abort
  if a:path =~# '*'
    return ['-e '.shellescape('Dir["./'.a:path.'"].each &method(:require)')] + a:args
  else
    return [a:path] + a:args
  endif
endfunction

function! test#ruby#minitest#executable() abort
  if system('cat Rakefile') =~# 'Rake::TestTask' ||
   \ (exists('b:rails_root') || filereadable('./bin/rails'))
    if !empty(glob('.zeus.sock'))
      return 'zeus rake test'
    elseif filereadable('./bin/rake')
      return './bin/rake test'
    elseif filereadable('Gemfile') && get(g:, 'test#ruby#bundle_exec', 1)
      return 'bundle exec rake test'
    else
      return 'rake test'
    endif
  else
    if filereadable('Gemfile') && get(g:, 'test#ruby#bundle_exec', 1)
      return 'bundle exec ruby -I test'
    else
      return 'ruby -I test'
    endif
  endif
endfunction

" http://chriskottom.com/blog/2014/12/command-line-flags-for-minitest-in-the-raw/
function! s:nearest_test(position) abort
  let syntax = s:syntax(a:position['file'])
  let name = test#base#nearest_test(a:position, g:test#ruby#patterns)

  let namespace = filter([test#base#escape_regex(join(name['namespace'], '::'))], '!empty(v:val)')
  if empty(name['test'])
    let test = []
  else
    let test_name = test#base#escape_regex(name['test'][0]).'$'
    if syntax == 'rails'    " test('foo') { ... }
      let test = ['test_'.substitute(test_name, '\s\+', '_', 'g')]
    elseif syntax == 'spec' " it('foo') { ... }
      let test = ['test_\d+_'.test_name]
    else
      let test = [test_name]
    endif
  endif

  return join(namespace + test, '#')
endfunction

function! s:syntax(file) abort
  let lines = split(system('cat '.a:file), '\n')

  if !empty(filter(copy(lines), 'v:val =~# g:test#ruby#patterns["test"][1]'))
    return 'rails'
  elseif !empty(filter(copy(lines), 'v:val =~# g:test#ruby#patterns["test"][2]'))
    return 'spec'
  else
    return 'test'
  endif
endfunction
