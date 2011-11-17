" Init section - set default values, highlight colors

let s:rdebug_port = 39767
let s:debugger_port = 39768
" hostname() returns something strange in Windows (E98BD9A419BB41D), so set hostname explicitly
let s:hostname = 'localhost' "hostname()
" ~/.vim for Linux, vimfiles for Windows
let s:runtime_dir = expand('<sfile>:h:h')
" File for communicating between intermediate Ruby script ruby_debugger.rb and
" this plugin
let s:tmp_file = s:runtime_dir . '/tmp/ruby_debugger'
let s:server_output_file = s:runtime_dir . '/tmp/ruby_debugger_output'
" Default id for sign of current line
let s:current_line_sign_id = 120
let s:separator = "++vim-ruby-debugger separator++"
let s:sign_id = 0

" Create tmp directory if it doesn't exist
if !isdirectory(s:runtime_dir . '/tmp')
  call mkdir(s:runtime_dir . '/tmp')
endif

" Init breakpoint signs
hi def link Breakpoint Error
sign define breakpoint linehl=Breakpoint  text=xx

" Init current line signs
hi def link CurrentLine DiffAdd 
sign define current_line linehl=CurrentLine text=>>

" Loads this file. Required for autoloading the code for this plugin
fun! ruby_debugger#load_debugger()
  if !s:check_prerequisites()
    finish
  endif
endf


" Check all requirements for the current plugin
fun! s:check_prerequisites()
  let problems = []
  if v:version < 700 
    call add(problems, "RubyDebugger: This plugin requires Vim >= 7.")
  endif
  if !has("clientserver")
    call add(problems, "RubyDebugger: This plugin requires +clientserver option")
  endif
  if !executable("rdebug-ide")
    call add(problems, "RubyDebugger: You don't have installed 'ruby-debug-ide' gem or executable 'rdebug-ide' can't be found in your PATH")
  endif
  if !(has("win32") || has("win64")) && !executable("lsof")
    call add(problems, "RubyDebugger: You don't have 'lsof' installed or executable 'lsof' can't be found in your PATH")
  endif
  if g:ruby_debugger_builtin_sender && !has("ruby")
    call add(problems, "RubyDebugger: You are trying to use built-in Ruby in Vim, but your Vim doesn't compiled with +ruby. Set g:ruby_debugger_builtin_sender = 0 in your .vimrc to resolve that issue.")
  end
  if empty(problems)
    return 1
  else
    for p in problems
      echoerr p
    endfor
    return 0
  endif
endf


" End of init section


" *** Common (global) functions

" Split string of tags to List. E.g., 
" <variables><variable name="a" value="b" /><variable name="c" value="d" /></variables>
" will be splitted to 
" [ '<variable name="a" value="b" />', '<variable name="c" value="d" />' ]
function! s:get_tags(cmd)
  let tags = []
  let cmd = a:cmd
  " Remove wrap tags
  let inner_tags_match = s:get_inner_tags(cmd)
  if !empty(inner_tags_match)
    " Then find every tag and remove it from source string
    let pattern = '<.\{-}\/>' 
    let inner_tags = inner_tags_match[1]
    let tagmatch = matchlist(inner_tags, pattern)
    while empty(tagmatch) == 0
      call add(tags, tagmatch[0])
      " These symbols are interpretated as special, we need to escape them
      let tagmatch[0] = escape(tagmatch[0], '[]~*\')
      " Remove it from source string
      let inner_tags = substitute(inner_tags, tagmatch[0], '', '')
      " Find next tag
      let tagmatch = matchlist(inner_tags, pattern)
    endwhile
  endif
  return tags
endfunction


" Return match of inner tags without wrap tags. E.g.:
" <variables><variable name="a" value="b" /></variables> mathes only <variable /> 
function! s:get_inner_tags(cmd)
  return matchlist(a:cmd, '^<.\{-}>\(.\{-}\)<\/.\{-}>$')
endfunction 


" Return Dict of attributes.
" E.g., from <variable name="a" value="b" /> it returns
" {'name' : 'a', 'value' : 'b'}
function! s:get_tag_attributes(cmd)
  let attributes = {}
  let cmd = a:cmd
  " Find type of used quotes (" or ')
  let quote_match = matchlist(cmd, "\\w\\+=\\(.\\)")
  let quote = empty(quote_match) ? "\"" : escape(quote_match[1], "'\"")
  let pattern = "\\(\\w\\+\\)=" . quote . "\\(.\\{-}\\)" . quote
  " Find every attribute and remove it from source string
  let attrmatch = matchlist(cmd, pattern) 
  while !empty(attrmatch)
    " Values of attributes can be escaped by HTML entities, unescape them
    let attributes[attrmatch[1]] = s:unescape_html(attrmatch[2])
    " These symbols are interpretated as special, we need to escape them
    let attrmatch[0] = escape(attrmatch[0], '[]~*\')
    " Remove it from source string
    let cmd = substitute(cmd, attrmatch[0], '', '')
    " Find next attribute
    let attrmatch = matchlist(cmd, pattern) 
  endwhile
  return attributes
endfunction


" Unescape HTML entities
function! s:unescape_html(html)
  let result = substitute(a:html, "&amp;", "\\&", "g")
  let result = substitute(result, "&quot;", "\"", "g")
  let result = substitute(result, "&lt;", "<", "g")
  let result = substitute(result, "&gt;", ">", "g")
  return result
endfunction


function! s:quotify(exp)
  let quoted = a:exp
  let quoted = substitute(quoted, "\"", "\\\\\"", 'g')
  return quoted
endfunction


" Get filename of current buffer
function! s:get_filename()
  return expand("%:p")
endfunction


" Send message to debugger. This function should never be used explicitly,
" only through g:RubyDebugger.send_command function
function! s:send_message_to_debugger(message)
  if g:ruby_debugger_fast_sender
    call system(s:runtime_dir . "/bin/socket " . s:hostname . " " . s:debugger_port . " \"" . a:message . "\"")
  else
    if g:ruby_debugger_builtin_sender
ruby << RUBY
  require 'socket'
  attempts = 0
  a = nil
  host = VIM::evaluate("s:hostname")
  port = VIM::evaluate("s:debugger_port")
  message = VIM::evaluate("a:message").gsub("\\\"", '"')
  begin
    a = TCPSocket.open(host, port)
    a.puts(message)
    a.close
  rescue Errno::ECONNREFUSED
   attempts += 1
   if attempts < 400
     sleep 0.05
     retry
   else
     puts("#{host}:#{port} can not be opened")
     exit
   end
  ensure
    a.close if a && !a.closed?
  end
RUBY
    else
      let script =  "ruby -e \"require 'socket'; "
      let script .= "attempts = 0; "
      let script .= "a = nil; "
      let script .= "begin; "
      let script .=   "a = TCPSocket.open('" . s:hostname . "', " . s:debugger_port . "); "
      let script .=   "a.puts(%q[" . substitute(substitute(a:message, '[', '\[', 'g'), ']', '\]', 'g') . "]);"
      let script .=   "a.close; "
      let script .= "rescue Errno::ECONNREFUSED; "
      let script .=   "attempts += 1; "
      let script .=   "if attempts < 400; "
      let script .=     "sleep 0.05; "
      let script .=     "retry; "
      let script .=   "else; "
      let script .=     "puts('" . s:hostname . ":" . s:debugger_port . " can not be opened'); "
      let script .=     "exit; "
      let script .=   "end; "
      let script .= "ensure; "
      let script .=   "a.close if a && !a.closed?; "
      let script .= "end; \""
      let output = system(script)
      if output =~ 'can not be opened'
        call g:RubyDebugger.logger.put("Can't send a message to rdebug - port is not opened") 
      endif
    endif
  endif
endfunction


function! s:unplace_sign_of_current_line()
  if has("signs")
    exe ":sign unplace " . s:current_line_sign_id
  endif
endfunction


" Remove all variables of current line, remove current line sign. Usually it
" is needed before next/step/cont commands
function! s:clear_current_state()
  call s:unplace_sign_of_current_line()
  let g:RubyDebugger.variables = {}
  let g:RubyDebugger.frames = []
  " Clear variables and frames window (just show our empty variables Dict)
  if s:variables_window.is_open()
    call s:variables_window.open()
  endif
  if s:frames_window.is_open()
    call s:frames_window.open()
  endif
endfunction


" Open given file and jump to given line
" (stolen from NERDTree)
function! s:jump_to_file(file, line)
  "if the file is already open in this tab then just stick the cursor in it
  let window_number = bufwinnr('^' . a:file . '$')
  if window_number != -1
    exe window_number . "wincmd w"
  else
    " Check if last accessed window is usable to use it
    " Usable window - not quickfix, explorer, modified, etc 
    if !s:is_window_usable(winnr("#"))
      exe s:first_normal_window() . "wincmd w"
    else
      " If it is usable, jump to it
      exe 'wincmd p'
    endif
    exe "edit " . a:file
  endif
  exe "normal " . a:line . "G"
endfunction


" Return 1 if window is usable (not quickfix, explorer, modified, only one 
" window, ...) 
function! s:is_window_usable(winnumber)
  "If there is only one window (winnr("$") - windows count)
  if winnr("$") ==# 1
    return 0
  endif

  " Current window number
  let oldwinnr = winnr()

  " Switch to given window and check it
  exe a:winnumber . "wincmd p"
  let specialWindow = getbufvar("%", '&buftype') != '' || getwinvar('%', '&previewwindow')
  let modified = &modified

  exe oldwinnr . "wincmd p"

  "if it is a special window, e.g. quickfix or another explorer plugin    
  if specialWindow
    return 0
  endif

  if &hidden
    return 1
  endif

  " If this window is modified, but there is another opened window with
  " current file, return 1. Otherwise - 0
  return !modified || s:buf_in_windows(winbufnr(a:winnumber)) >= 2
endfunction


" Determine the number of windows open to this buffer number.
function! s:buf_in_windows(buffer_number)
  let count = 0
  let window_number = 1
  while 1
    let buffer_number = winbufnr(window_number)
    if buffer_number < 0
      break
    endif
    if buffer_number ==# a:buffer_number
      let count = count + 1
    endif
    let window_number = window_number + 1
  endwhile

  return count
endfunction 


" Find first 'normal' window (not quickfix, explorer, etc)
function! s:first_normal_window()
  let i = 1
  while i <= winnr("$")
    let bnum = winbufnr(i)
    if bnum != -1 && getbufvar(bnum, '&buftype') ==# '' && !getwinvar(i, '&previewwindow')
      return i
    endif
    let i += 1
  endwhile
  return -1
endfunction

" *** Queue class (start)

let s:Queue = {}

" ** Public methods

" Constructor of new queue.
function! s:Queue.new() dict
  let var = copy(self)
  let var.queue = []
  let var.after = ""
  return var
endfunction


" Execute next command in the queue and remove it from queue
function! s:Queue.execute() dict
  if !empty(self.queue)
    let message = join(self.queue, s:separator)
    call self.empty()
    call g:RubyDebugger.send_command(message)
  endif
endfunction


" Execute 'after' hook only if queue is empty
function! s:Queue.after_hook() dict
  if self.after != "" && empty(self.queue)
    call self.after()
  endif
endfunction


function! s:Queue.add(element) dict
  call add(self.queue, a:element)
endfunction


function! s:Queue.empty() dict
  let self.queue = []
endfunction


" *** Queue class (end)




" *** Public interface (start)

let RubyDebugger = { 'commands': {}, 'variables': {}, 'settings': {}, 'breakpoints': [], 'frames': [], 'exceptions': [] }
let g:RubyDebugger.queue = s:Queue.new()


" Run debugger server. It takes one optional argument with path to debugged
" ruby script ('script/server webrick' by default)
function! RubyDebugger.start(...) dict
  let g:RubyDebugger.server = s:Server.new(s:hostname, s:rdebug_port, s:debugger_port, s:runtime_dir, s:tmp_file, s:server_output_file)
  let script_string = a:0 && !empty(a:1) ? a:1 : 'script/server webrick'
  if script_string[0] != '/'
    let script_string = "'" . getcwd() . '/' . substitute(script_string, "'", "", "g") . "'"
  endif

  echo "Loading debugger..."
  call g:RubyDebugger.server.start(script_string)

  let g:RubyDebugger.exceptions = []
  for breakpoint in g:RubyDebugger.breakpoints
    call g:RubyDebugger.queue.add(breakpoint.command())
  endfor
  call g:RubyDebugger.queue.add('start')
  echo "Debugger started"
  call g:RubyDebugger.queue.execute()
endfunction


" Stop running server.
function! RubyDebugger.stop() dict
  if has_key(g:RubyDebugger, 'server')
    call g:RubyDebugger.server.stop()
  endif
endfunction


" This function receives commands from the debugger. When ruby_debugger.rb
" gets output from rdebug-ide, it writes it to the special file and 'kick'
" the plugin by remotely calling RubyDebugger.receive_command(), e.g.:
" vim --servername VIM --remote-send 'call RubyDebugger.receive_command()'
" That's why +clientserver is required
" This function analyzes the special file and gives handling to right command
function! RubyDebugger.receive_command() dict
  let file_contents = join(readfile(s:tmp_file), "")
  call g:RubyDebugger.logger.put("Received command: " . file_contents)
  let commands = split(file_contents, s:separator)
  for cmd in commands
    if !empty(cmd)
      if match(cmd, '<breakpoint ') != -1
        call g:RubyDebugger.commands.jump_to_breakpoint(cmd)
      elseif match(cmd, '<suspended ') != -1
        call g:RubyDebugger.commands.jump_to_breakpoint(cmd)
      elseif match(cmd, '<exception ') != -1
        call g:RubyDebugger.commands.handle_exception(cmd)
      elseif match(cmd, '<breakpointAdded ') != -1
        call g:RubyDebugger.commands.set_breakpoint(cmd)
      elseif match(cmd, '<catchpointSet ') != -1
        call g:RubyDebugger.commands.set_exception(cmd)
      elseif match(cmd, '<variables>') != -1
        call g:RubyDebugger.commands.set_variables(cmd)
      elseif match(cmd, '<error>') != -1
        call g:RubyDebugger.commands.error(cmd)
      elseif match(cmd, '<message>') != -1
        call g:RubyDebugger.commands.message(cmd)
      elseif match(cmd, '<eval ') != -1
        call g:RubyDebugger.commands.eval(cmd)
      elseif match(cmd, '<processingException ') != -1
        call g:RubyDebugger.commands.processing_exception(cmd)
      elseif match(cmd, '<frames>') != -1
        call g:RubyDebugger.commands.trace(cmd)
      endif
    endif
  endfor
  call g:RubyDebugger.queue.after_hook()
  call g:RubyDebugger.queue.execute()
endfunction


function! RubyDebugger.send_command_wrapper(command)
  call g:RubyDebugger.send_command(a:command)
endfunction

" We set function this way, because we want have possibility to mock it by
" other function in tests
let RubyDebugger.send_command = function("<SID>send_message_to_debugger")


" Open variables window
function! RubyDebugger.open_variables() dict
  call s:variables_window.toggle()
  call g:RubyDebugger.logger.put("Opened variables window")
  call g:RubyDebugger.queue.execute()
endfunction


" Open breakpoints window
function! RubyDebugger.open_breakpoints() dict
  call s:breakpoints_window.toggle()
  call g:RubyDebugger.logger.put("Opened breakpoints window")
  call g:RubyDebugger.queue.execute()
endfunction


" Open frames window
function! RubyDebugger.open_frames() dict
  call s:frames_window.toggle()
  call g:RubyDebugger.logger.put("Opened frames window")
  call g:RubyDebugger.queue.execute()
endfunction


" Set/remove breakpoint at current position. If argument
" is given, it will set conditional breakpoint (argument is condition)
function! RubyDebugger.toggle_breakpoint(...) dict
  let line = line(".")
  let file = s:get_filename()
  let existed_breakpoints = filter(copy(g:RubyDebugger.breakpoints), 'v:val.line == ' . line . ' && v:val.file == "' . escape(file, '\') . '"')
  " If breakpoint with current file/line doesn't exist, create it. Otherwise -
  " remove it
  if empty(existed_breakpoints)
    let breakpoint = s:Breakpoint.new(file, line)
    call add(g:RubyDebugger.breakpoints, breakpoint)
    call breakpoint.send_to_debugger() 
  else
    let breakpoint = existed_breakpoints[0]
    call filter(g:RubyDebugger.breakpoints, 'v:val.id != ' . breakpoint.id)
    call breakpoint.delete()
  endif
  " Update info in Breakpoints window
  if s:breakpoints_window.is_open()
    call s:breakpoints_window.open()
    exe "wincmd p"
  endif
  call g:RubyDebugger.queue.execute()
endfunction


" Remove all breakpoints
function! RubyDebugger.remove_breakpoints() dict
  for breakpoint in g:RubyDebugger.breakpoints
    call breakpoint.delete()
  endfor
  let g:RubyDebugger.breakpoints = []
  call g:RubyDebugger.queue.execute()
endfunction


" Eval the passed in expression
function! RubyDebugger.eval(exp) dict
  let quoted = s:quotify(a:exp)
  call g:RubyDebugger.queue.add("eval " . quoted)
  call g:RubyDebugger.queue.execute()
endfunction


" Sets conditional breakpoint where cursor is placed
function! RubyDebugger.conditional_breakpoint(exp) dict
  let line = line(".")
  let file = s:get_filename()
  let existed_breakpoints = filter(copy(g:RubyDebugger.breakpoints), 'v:val.line == ' . line . ' && v:val.file == "' . escape(file, '\') . '"')
  " If breakpoint with current file/line doesn't exist, create it. Otherwise -
  " remove it
  if empty(existed_breakpoints)
    echo "You can set condition only to already set breakpoints. Move cursor to set breakpoint and add condition"
  else
    let breakpoint = existed_breakpoints[0]
    let quoted = s:quotify(a:exp)
    call breakpoint.add_condition(quoted)
    " Update info in Breakpoints window
    if s:breakpoints_window.is_open()
      call s:breakpoints_window.open()
      exe "wincmd p"
    endif
    call g:RubyDebugger.queue.execute()
  endif
endfunction


" Catch all exceptions with given name
function! RubyDebugger.catch_exception(exp) dict
  if has_key(g:RubyDebugger, 'server') && g:RubyDebugger.server.is_running()
    let quoted = s:quotify(a:exp)
    let exception = s:Exception.new(quoted)
    call add(g:RubyDebugger.exceptions, exception)
    if s:breakpoints_window.is_open()
      call s:breakpoints_window.open()
      exe "wincmd p"
    endif
    call g:RubyDebugger.queue.execute()
  else
    echo "Sorry, but you can set Exceptional Breakpoints only with running debugger"
  endif
endfunction


" Next
function! RubyDebugger.next() dict
  call g:RubyDebugger.queue.add("next")
  call s:clear_current_state()
  call g:RubyDebugger.logger.put("Step over")
  call g:RubyDebugger.queue.execute()
endfunction


" Step
function! RubyDebugger.step() dict
  call g:RubyDebugger.queue.add("step")
  call s:clear_current_state()
  call g:RubyDebugger.logger.put("Step into")
  call g:RubyDebugger.queue.execute()
endfunction


" Finish
function! RubyDebugger.finish() dict
  call g:RubyDebugger.queue.add("finish")
  call s:clear_current_state()
  call g:RubyDebugger.logger.put("Step out")
  call g:RubyDebugger.queue.execute()
endfunction


" Continue
function! RubyDebugger.continue() dict
  call g:RubyDebugger.queue.add("cont")
  call s:clear_current_state()
  call g:RubyDebugger.logger.put("Continue")
  call g:RubyDebugger.queue.execute()
endfunction


" Exit
function! RubyDebugger.exit() dict
  call g:RubyDebugger.queue.add("exit")
  call s:clear_current_state()
  call g:RubyDebugger.queue.execute()
endfunction


" Show output log of Ruby script
function! RubyDebugger.show_log() dict
  exe "view " . s:server_output_file
  setlocal autoread
  " Per gorkunov's request 
  setlocal wrap
  setlocal nonumber
  if exists(":AnsiEsc")
    exec ":AnsiEsc"
  endif
endfunction


" Debug current opened test
function! RubyDebugger.run_test() dict
  let file = s:get_filename()
  if file =~ '_spec\.rb$'
    call g:RubyDebugger.start(g:ruby_debugger_spec_path . ' ' . file)
  elseif file =~ '\.feature$'
    call g:RubyDebugger.start(g:ruby_debugger_cucumber_path . ' ' . file)
  elseif file =~ '_test\.rb$'
    call g:RubyDebugger.start(file)
  endif
endfunction


" *** Public interface (end)




" *** RubyDebugger Commands (what debugger returns)


" <breakpoint file="test.rb" line="1" threadId="1" />
" <suspended file='test.rb' line='1' threadId='1' />
" Jump to file/line where execution was suspended, set current line sign and get local variables
function! RubyDebugger.commands.jump_to_breakpoint(cmd) dict
  let attrs = s:get_tag_attributes(a:cmd) 
  call s:jump_to_file(attrs.file, attrs.line)
  call g:RubyDebugger.logger.put("Jumped to breakpoint " . attrs.file . ":" . attrs.line)

  if has("signs")
    exe ":sign place " . s:current_line_sign_id . " line=" . attrs.line . " name=current_line file=" . attrs.file
  endif
endfunction


" <exception file="test.rb" line="1" type="NameError" message="some exception message" threadId="4" />
" Show message error and jump to given file/line
function! RubyDebugger.commands.handle_exception(cmd) dict
  let message_match = matchlist(a:cmd, 'message="\(.\{-}\)"')
  call g:RubyDebugger.commands.jump_to_breakpoint(a:cmd)
  echo "Exception message: " . s:unescape_html(message_match[1])
endfunction


" <catchpointSet exception="NoMethodError"/>
" Confirm setting of exception catcher
function! RubyDebugger.commands.set_exception(cmd) dict
  let attrs = s:get_tag_attributes(a:cmd)
  call g:RubyDebugger.logger.put("Exception successfully set: " . attrs.exception)
endfunction


" <breakpointAdded no="1" location="test.rb:2" />
" Add debugger info to breakpoints (pid of debugger, debugger breakpoint's id)
" Assign rest breakpoints to debugger recursively, if there are breakpoints
" from old server runnings or not assigned breakpoints (e.g., if you at first
" set some breakpoints, and then run the debugger by :Rdebugger)
function! RubyDebugger.commands.set_breakpoint(cmd)
  let attrs = s:get_tag_attributes(a:cmd)
  let file_match = matchlist(attrs.location, '\(.*\):\(.*\)')
  let pid = g:RubyDebugger.server.rdebug_pid

  " Find added breakpoint in array and assign debugger's info to it
  for breakpoint in g:RubyDebugger.breakpoints
    if expand(breakpoint.file) == expand(file_match[1]) && expand(breakpoint.line) == expand(file_match[2])
      let breakpoint.debugger_id = attrs.no
      let breakpoint.rdebug_pid = pid
      if has_key(breakpoint, 'condition')
        call breakpoint.add_condition(breakpoint.condition)
      endif
    endif
  endfor

  call g:RubyDebugger.logger.put("Breakpoint is set: " . file_match[1] . ":" . file_match[2])
  call g:RubyDebugger.queue.execute()
endfunction


" <variables>
"   <variable name="array" kind="local" value="Array (2 element(s))" type="Array" hasChildren="true" objectId="-0x2418a904"/>
" </variables>
" Assign list of got variables to parent variable and (optionally) show them
function! RubyDebugger.commands.set_variables(cmd)
  let tags = s:get_tags(a:cmd)
  let list_of_variables = []

  " Create hash from list of tags
  for tag in tags
    let attrs = s:get_tag_attributes(tag)
    let variable = s:Var.new(attrs)
    call add(list_of_variables, variable)
  endfor

  " If there is no variables, create unnamed root variable. Local variables
  " will be chilren of this variable
  if g:RubyDebugger.variables == {}
    let g:RubyDebugger.variables = s:VarParent.new({'hasChildren': 'true'})
    let g:RubyDebugger.variables.is_open = 1
    let g:RubyDebugger.variables.children = []
  endif

  " If g:RubyDebugger.current_variable exists, then it contains parent
  " variable of got subvariables. Assign them to it.
  if has_key(g:RubyDebugger, 'current_variable')
    let variable = g:RubyDebugger.current_variable
    if variable != {}
      call variable.add_childs(list_of_variables)
      call g:RubyDebugger.logger.put("Opening child variable: " . variable.attributes.objectId)
      " Variables Window is always open if we got subvariables
      call s:variables_window.open()
    else
      call g:RubyDebugger.logger.put("Can't found variable")
    endif
    unlet g:RubyDebugger.current_variable
  else
    " Otherwise, assign them to unnamed root variable
    if g:RubyDebugger.variables.children == []
      call g:RubyDebugger.variables.add_childs(list_of_variables)
      call g:RubyDebugger.logger.put("Initializing local variables")
      if s:variables_window.is_open()
        " show variables only if Variables Window is open
        call s:variables_window.open()
      endif
    endif
  endif

endfunction


" <eval expression="User.all" value="[#User ... ]" />
" Just show result of evaluation
function! RubyDebugger.commands.eval(cmd)
  " rdebug-ide-gem doesn't escape attributes of tag properly, so we should not
  " use usual attribute extractor here...
  let match = matchlist(a:cmd, "<eval expression=\"\\(.\\{-}\\)\" value=\"\\(.*\\)\" \\/>")
  echo "Evaluated expression:\n" . s:unescape_html(match[1]) ."\nResulted value is:\n" . match[2] . "\n"
endfunction


" <processingException type="SyntaxError" message="some message" />
" Just show exception message
function! RubyDebugger.commands.processing_exception(cmd)
  let attrs = s:get_tag_attributes(a:cmd) 
  let message = "RubyDebugger Exception, type: " . attrs.type . ", message: " . attrs.message
  echo message
  call g:RubyDebugger.logger.put(message)
endfunction


" <frames>
"   <frame no='1' file='/path/to/file.rb' line='21' current='true' />
"   <frame no='2' file='/path/to/file.rb' line='11' />
" </frames>
" Assign all frames, fill Frames window by them
function! RubyDebugger.commands.trace(cmd)
  let tags = s:get_tags(a:cmd)
  let list_of_frames = []

  " Create hash from list of tags
  for tag in tags
    let attrs = s:get_tag_attributes(tag)
    let frame = s:Frame.new(attrs)
    call add(list_of_frames, frame)
  endfor

  let g:RubyDebugger.frames = list_of_frames

  if s:frames_window.is_open()
    " show backtrace only if Backtrace Window is open
    call s:frames_window.open()
  endif
endfunction


" <error>Error</error>
" Just show error
function! RubyDebugger.commands.error(cmd)
  let error_match = s:get_inner_tags(a:cmd) 
  if !empty(error_match)
    let error = error_match[1]
    echo "RubyDebugger Error: " . error
    call g:RubyDebugger.logger.put("Got error: " . error)
  endif
endfunction


" <message>Message</message>
" Just show message
function! RubyDebugger.commands.message(cmd)
  let message_match = s:get_inner_tags(a:cmd) 
  if !empty(message_match)
    let message = message_match[1]
    echo "RubyDebugger Message: " . message
    call g:RubyDebugger.logger.put("Got message: " . message)
  endif
endfunction


" *** End of debugger Commands 



" *** Window class (start). Abstract Class for creating window. 
"     Must be inherited. Mostly, stolen from the NERDTree.

let s:Window = {} 
let s:Window['next_buffer_number'] = 1 
let s:Window['position'] = 'botright'
let s:Window['size'] = 10

" ** Public methods

" Constructs new window
function! s:Window.new(name, title) dict
  let new_variable = copy(self)
  let new_variable.name = a:name
  let new_variable.title = a:title
  return new_variable
endfunction


" Clear all data from window
function! s:Window.clear() dict
  silent 1,$delete _
endfunction


" Close window
function! s:Window.close() dict
  if !self.is_open()
    throw "RubyDebug: Window " . self.name . " is not open"
  endif

  if winnr("$") != 1
    call self.focus()
    close
    exe "wincmd p"
  else
    " If this is only one window, just quit
    :q
  endif
  call self._log("Closed window with name: " . self.name)
endfunction


" Get window number
function! s:Window.get_number() dict
  if self._exist_for_tab()
    return bufwinnr(self._buf_name())
  else
    return -1
  endif
endfunction


" Display data to the window
function! s:Window.display()
  call self._log("Start displaying data in window with name: " . self.name)
  call self.focus()
  setlocal modifiable

  let current_line = line(".")
  let current_column = col(".")
  let top_line = line("w0")

  call self.clear()

  call self._insert_data()
  call self._restore_view(top_line, current_line, current_column)

  setlocal nomodifiable
  call self._log("Complete displaying data in window with name: " . self.name)
endfunction


" Put cursor to the window
function! s:Window.focus() dict
  exe self.get_number() . " wincmd w"
  call self._log("Set focus to window with name: " . self.name)
endfunction


" Return 1 if window is opened
function! s:Window.is_open() dict
    return self.get_number() != -1
endfunction


" Open window and display data (stolen from NERDTree)
function! s:Window.open() dict
    if !self.is_open()
      " create the window
      silent exec self.position . ' ' . self.size . ' new'

      if !self._exist_for_tab()
        " If the window is not opened/exists, create new
        call self._set_buf_name(self._next_buffer_name())
        silent! exec "edit " . self._buf_name()
        " This function does not exist in Window class and should be declared in
        " descendants
        call self.bind_mappings()
      else
        " Or just jump to opened buffer
        silent! exec "buffer " . self._buf_name()
      endif

      " set buffer options
      setlocal winfixheight
      setlocal noswapfile
      setlocal buftype=nofile
      setlocal nowrap
      setlocal foldcolumn=0
      setlocal nobuflisted
      setlocal nospell
      setlocal nolist
      iabc <buffer>
      setlocal cursorline
      setfiletype ruby_debugger_window
      call self._log("Opened window with name: " . self.name)
    endif

    if has("syntax") && exists("g:syntax_on") && !has("syntax_items")
      call self.setup_syntax_highlighting()
    endif

    call self.display()
endfunction


" Open/close window
function! s:Window.toggle() dict
  call self._log("Toggling window with name: " . self.name)
  if self._exist_for_tab() && self.is_open()
    call self.close()
  else
    call self.open()
  end
endfunction


" ** Private methods


" Return buffer name, that is stored in tab variable
function! s:Window._buf_name() dict
  return t:window_{self.name}_buf_name
endfunction


" Return 1 if the window exists in current tab
function! s:Window._exist_for_tab() dict
  return exists("t:window_" . self.name . "_buf_name") 
endfunction


" Insert data to the window
function! s:Window._insert_data() dict
  let old_p = @p
  " Put data to the register and then show it by 'put' command
  let @p = self.render()
  silent exe "normal \"pP"
  let @p = old_p
  call self._log("Inserted data to window with name: " . self.name)
endfunction


function! s:Window._log(string) dict
  if has_key(self, 'logger')
    call self.logger.put(a:string)
  endif
endfunction


" Calculate correct name for the window
function! s:Window._next_buffer_name() dict
  let name = self.name . s:Window.next_buffer_number
  let s:Window.next_buffer_number += 1
  return name
endfunction


" Restore the view
function! s:Window._restore_view(top_line, current_line, current_column) dict
  let old_scrolloff=&scrolloff
  let &scrolloff=0
  call cursor(a:top_line, 1)
  normal! zt
  call cursor(a:current_line, a:current_column)
  let &scrolloff = old_scrolloff 
  call self._log("Restored view of window with name: " . self.name)
endfunction


function! s:Window._set_buf_name(name) dict
  let t:window_{self.name}_buf_name = a:name
endfunction


" *** Window class (end)



" *** WindowVariables class (start)

" Inherits variables window from abstract window class
let s:WindowVariables = copy(s:Window)

" ** Public methods

function! s:WindowVariables.bind_mappings()
  nnoremap <buffer> <2-leftmouse> :call <SID>window_variables_activate_node()<cr>
  nnoremap <buffer> o :call <SID>window_variables_activate_node()<cr>"
endfunction


" Returns string that contains all variables (for Window.display())
function! s:WindowVariables.render() dict
  let variables = self.title . "\n"
  let variables .= (g:RubyDebugger.variables == {} ? '' : g:RubyDebugger.variables.render())
  return variables
endfunction


" TODO: Is there some way to call s:WindowVariables.activate_node from mapping
" command?
" Expand/collapse variable under cursor
function! s:window_variables_activate_node()
  let variable = s:Var.get_selected()
  if variable != {} && variable.type == "VarParent"
    if variable.is_open
      call variable.close()
    else
      call variable.open()
    endif
  endif
  call g:RubyDebugger.queue.execute()
endfunction


" Add syntax highlighting
function! s:WindowVariables.setup_syntax_highlighting()
    execute "syn match rdebugTitle #" . self.title . "#"

    syn match rdebugPart #[| `]\+#
    syn match rdebugPartFile #[| `]\+-# contains=rdebugPart nextgroup=rdebugChild contained
    syn match rdebugChild #.\{-}\t# nextgroup=rdebugType contained

    syn match rdebugClosable #[| `]\+\~# contains=rdebugPart nextgroup=rdebugParent contained
    syn match rdebugOpenable #[| `]\++# contains=rdebugPart nextgroup=rdebugParent contained
    syn match rdebugParent #.\{-}\t# nextgroup=rdebugType contained

    syn match rdebugType #.\{-}\t# nextgroup=rdebugValue contained
    syn match rdebugValue #.*\t#he=e-1 nextgroup=rdebugId contained
    syn match rdebugId #.*# contained

    syn match rdebugParentLine '[| `]\+[+\~].*' contains=rdebugClosable,rdebugOpenable transparent
    syn match rdebugChildLine '[| `]\+-.*' contains=rdebugPartFile transparent

    hi def link rdebugTitle Identifier
    hi def link rdebugClosable Type
    hi def link rdebugOpenable Title
    hi def link rdebugPart Special
    hi def link rdebugPartFile Type
    hi def link rdebugChild Normal
    hi def link rdebugParent Directory
    hi def link rdebugType Type
    hi def link rdebugValue Special
    hi def link rdebugId Ignore
endfunction


" *** WindowVariables class (end)



" *** WindowBreakpoints class (start)

" Inherits WindowBreakpoints from Window
let s:WindowBreakpoints = copy(s:Window)

" ** Public methods

function! s:WindowBreakpoints.bind_mappings()
  nnoremap <buffer> <2-leftmouse> :call <SID>window_breakpoints_activate_node()<cr>
  nnoremap <buffer> o :call <SID>window_breakpoints_activate_node()<cr>
  nnoremap <buffer> d :call <SID>window_breakpoints_delete_node()<cr>
endfunction


" Returns string that contains all breakpoints (for Window.display())
function! s:WindowBreakpoints.render() dict
  let breakpoints = ""
  let breakpoints .= self.title . "\n"
  for breakpoint in g:RubyDebugger.breakpoints
    let breakpoints .= breakpoint.render()
  endfor
  let exceptions = map(copy(g:RubyDebugger.exceptions), 'v:val.render()')
  let breakpoints .= "\nException breakpoints: " . join(exceptions, ", ")
  return breakpoints
endfunction


" TODO: Is there some way to call s:WindowBreakpoints.activate_node from mapping
" command?
" Open breakpoint under cursor
function! s:window_breakpoints_activate_node()
  let breakpoint = s:Breakpoint.get_selected()
  if breakpoint != {}
    call breakpoint.open()
  endif
endfunction


" Delete breakpoint under cursor
function! s:window_breakpoints_delete_node()
  let breakpoint = s:Breakpoint.get_selected()
  if breakpoint != {}
    call breakpoint.delete()
    call filter(g:RubyDebugger.breakpoints, "v:val.id != " . breakpoint.id)
    call s:breakpoints_window.open()
  endif
endfunction


" Add syntax highlighting
function! s:WindowBreakpoints.setup_syntax_highlighting() dict
    execute "syn match rdebugTitle #" . self.title . "#"

    syn match rdebugId "^\d\+\s" contained nextgroup=rdebugDebuggerId
    syn match rdebugDebuggerId "\d*\s" contained nextgroup=rdebugFile
    syn match rdebugFile ".*:" contained nextgroup=rdebugLine
    syn match rdebugLine "\d\+" contained

    syn match rdebugWrapper "^\d\+.*" contains=rdebugId transparent

    hi def link rdebugId Directory
    hi def link rdebugDebuggerId Type
    hi def link rdebugFile Normal
    hi def link rdebugLine Special
endfunction


" *** WindowBreakpoints class (end)



" *** WindowFrames class (start)

" Inherits WindowFrames from Window
let s:WindowFrames = copy(s:Window)

" ** Public methods

function! s:WindowFrames.bind_mappings()
  nnoremap <buffer> <2-leftmouse> :call <SID>window_frames_activate_node()<cr>
  nnoremap <buffer> o :call <SID>window_frames_activate_node()<cr>
endfunction


" Returns string that contains all frames (for Window.display())
function! s:WindowFrames.render() dict
  let frames = ""
  let frames .= self.title . "\n"
  for frame in g:RubyDebugger.frames
    let frames .= frame.render()
  endfor
  return frames
endfunction


" Open frame under cursor
function! s:window_frames_activate_node()
  let frame = s:Frame.get_selected()
  if frame != {}
    call frame.open()
  endif
endfunction


" Add syntax highlighting
function! s:WindowFrames.setup_syntax_highlighting() dict
    execute "syn match rdebugTitle #" . self.title . "#"

    syn match rdebugId "^\d\+\s" contained nextgroup=rdebugFile
    syn match rdebugFile ".*:" contained nextgroup=rdebugLine
    syn match rdebugLine "\d\+" contained

    syn match rdebugWrapper "^\d\+.*" contains=rdebugId transparent

    hi def link rdebugId Directory
    hi def link rdebugFile Normal
    hi def link rdebugLine Special
endfunction


" *** WindowFrames class (end)




" *** Var proxy class (start)

let s:Var = { 'id' : 0 }

" ** Public methods

" This is a proxy method for creating new variable
function! s:Var.new(attrs)
  if has_key(a:attrs, 'hasChildren') && a:attrs['hasChildren'] == 'true'
    return s:VarParent.new(a:attrs)
  else
    return s:VarChild.new(a:attrs)
  end
endfunction


" Get variable under cursor
function! s:Var.get_selected()
  let line = getline(".") 
  " Get its id - it is last in the string
  let match = matchlist(line, '.*\t\(\d\+\)$') 
  let id = get(match, 1)
  if id
    let variable = g:RubyDebugger.variables.find_variable({'id' : id})
    return variable
  else
    return {}
  endif
endfunction


" *** Var proxy class (end)



" *** VarChild class (start)

let s:VarChild = {}

" ** Public methods

" Constructs new variable without childs
function! s:VarChild.new(attrs)
  let new_variable = copy(self)
  let new_variable.attributes = a:attrs
  let new_variable.parent = {}
  let new_variable.level = 0
  let new_variable.type = "VarChild"
  let s:Var.id += 1
  let new_variable.id = s:Var.id
  return new_variable
endfunction


" Renders data of the variable
function! s:VarChild.render()
  return self._render(0, 0, [], len(self.parent.children) ==# 1)
endfunction


" VarChild can't be opened because it can't have children. But VarParent can
function! s:VarChild.open()
  return 0
endfunction


" VarChild can't be closed because it can't have children. But VarParent can
function! s:VarChild.close()
  return 0
endfunction


" VarChild can't be parent. But VarParent can. If Var have hasChildren ==
" true, then it is parent
function! s:VarChild.is_parent()
  return has_key(self.attributes, 'hasChildren') && get(self.attributes, 'hasChildren') ==# 'true'
endfunction


" Output format for Variables Window
function! s:VarChild.to_s()
  return get(self.attributes, "name", "undefined") . "\t" . get(self.attributes, "type", "undefined") . "\t" . get(self.attributes, "value", "undefined") . "\t" . get(self, "id", "0")
endfunction


" Find and return variable by given Dict of attrs, e.g.: {'name' : 'var1'}
function! s:VarChild.find_variable(attrs)
  if self._match_attributes(a:attrs)
    return self
  else
    return {}
  endif
endfunction


" Find and return array of variables that match given Dict of attrs
function! s:VarChild.find_variables(attrs)
  let variables = []
  if self._match_attributes(a:attrs)
    call add(variables, self)
  endif
  return variables
endfunction


" ** Private methods


" Recursive function, that renders Variable and all its childs (if they are
" presented). Stolen from NERDTree
function! s:VarChild._render(depth, draw_text, vertical_map, is_last_child)
  let output = ""
  if a:draw_text ==# 1
    let tree_parts = ''

    " get all the leading spaces and vertical tree parts for this line
    if a:depth > 1
      for j in a:vertical_map[0:-2]
        if j ==# 1
          let tree_parts = tree_parts . '| '
        else
          let tree_parts = tree_parts . '  '
        endif
      endfor
    endif
    
    " get the last vertical tree part for this line which will be different
    " if this node is the last child of its parent
    if a:is_last_child
      let tree_parts = tree_parts . '`'
    else
      let tree_parts = tree_parts . '|'
    endif

    " smack the appropriate dir/file symbol on the line before the file/dir
    " name itself
    if self.is_parent()
      if self.is_open
        let tree_parts = tree_parts . '~'
      else
        let tree_parts = tree_parts . '+'
      endif
    else
      let tree_parts = tree_parts . '-'
    endif
    let line = tree_parts . self.to_s()
    let output = output . line . "\n"

  endif

  if self.is_parent() && self.is_open
    if len(self.children) > 0

      " draw all the nodes children except the last
      let last_index = len(self.children) - 1
      if last_index > 0
        for i in self.children[0:last_index - 1]
          let output = output . i._render(a:depth + 1, 1, add(copy(a:vertical_map), 1), 0)
        endfor
      endif

      " draw the last child, indicating that it IS the last
      let output = output . self.children[last_index]._render(a:depth + 1, 1, add(copy(a:vertical_map), 0), 1)

    endif
  endif

  return output

endfunction


" Return 1 if *all* given attributes (pairs key/value) match to current
" variable
function! s:VarChild._match_attributes(attrs)
  let conditions = 1
  for attr in keys(a:attrs)
    if has_key(self.attributes, attr)
      " If current key is contained in attributes of variable (they were
      " attributes in <variable /> tag, then trying to match there.
      let conditions = conditions && self.attributes[attr] == a:attrs[attr] 
    elseif has_key(self, attr)
      " Otherwise, if current key is contained in auxiliary attributes of the
      " variable, trying to match there
      let conditions = conditions && self[attr] == a:attrs[attr]
    else
      " Otherwise, this variable is not match
      let conditions = 0
      break
    endif
  endfor
  return conditions
endfunction


" *** VarChild class (end)




" *** VarParent class (start)

" Inherits VarParent from VarChild
let s:VarParent = copy(s:VarChild)

" ** Public methods


" Initializes new variable with childs
function! s:VarParent.new(attrs)
  if !has_key(a:attrs, 'hasChildren') || a:attrs['hasChildren'] != 'true'
    throw "RubyDebug: VarParent must be initialized with hasChildren = true"
  endif
  let new_variable = copy(self)
  let new_variable.attributes = a:attrs
  let new_variable.parent = {}
  let new_variable.is_open = 0
  let new_variable.level = 0
  let new_variable.children = []
  let new_variable.type = "VarParent"
  let s:Var.id += 1
  let new_variable.id = s:Var.id
  return new_variable
endfunction


" Open variable, init its children and display them
function! s:VarParent.open()
  let self.is_open = 1
  call self._init_children()
  return 0
endfunction


" Close variable and display it
function! s:VarParent.close()
  let self.is_open = 0
  call s:variables_window.display()
  if has_key(g:RubyDebugger, "current_variable")
    unlet g:RubyDebugger.current_variable
  endif
  return 0
endfunction


" Renders data of the variable
function! s:VarParent.render()
  return self._render(0, 0, [], len(self.children) ==# 1)
endfunction



" Add childs to the variable. You always should use this method instead of
" explicit assigning to children property (like 'add(self.children, variables)')
function! s:VarParent.add_childs(childs)
  " If children are given by array, extend self.children by this array
  if type(a:childs) == type([])
    for child in a:childs
      let child.parent = self
      let child.level = self.level + 1
    endfor
    call extend(self.children, a:childs)
  else
    " Otherwise, add child to self.children
    let a:childs.parent = self
    let child.level = self.level + 1
    call add(self.children, a:childs)
  end
endfunction


" Find and return variable by given Dict of attrs, e.g.: {'name' : 'var1'}
" If current variable doesn't match these attributes, try to find in children
function! s:VarParent.find_variable(attrs)
  if self._match_attributes(a:attrs)
    return self
  else
    for child in self.children
      let result = child.find_variable(a:attrs)
      if result != {}
        return result
      endif
    endfor
  endif
  return {}
endfunction


" Find and return array of variables that match given Dict of attrs.
" Try to match current variable and its children
function! s:VarParent.find_variables(attrs)
  let variables = []
  if self._match_attributes(a:attrs)
    call add(variables, self)
  endif
  for child in self.children
    call extend(variables, child.find_variables(a:attrs))
  endfor
  return variables
endfunction


" ** Private methods


" Update children of the variable
function! s:VarParent._init_children()
  " Remove all the current child nodes
  let self.children = []

  " Get children
  if has_key(self.attributes, 'objectId')
    let g:RubyDebugger.current_variable = self
    call g:RubyDebugger.queue.add('var instance ' . self.attributes.objectId)
  endif

endfunction


" *** VarParent class (end)



" *** Logger class (start)


let s:Logger = {} 

function! s:Logger.new(file)
  let new_variable = copy(self)
  let new_variable.file = a:file
  call writefile([], new_variable.file)
  return new_variable
endfunction


" Log datetime and then message
function! s:Logger.put(string)
  let file = readfile(self.file)
  let string = strftime("%Y/%m/%d %H:%M:%S") . ' ' . a:string
  call add(file, string)
  call writefile(file, self.file)
endfunction


" *** Logger class (end)


" *** Breakpoint class (start)

let s:Breakpoint = { 'id': 0 }

" ** Public methods

" Constructor of new brekpoint. Create new breakpoint and set sign.
function! s:Breakpoint.new(file, line)
  let var = copy(self)
  let var.file = a:file
  let var.line = a:line
  let s:Breakpoint.id += 1
  let var.id = s:Breakpoint.id

  call var._set_sign()
  call var._log("Set breakpoint to: " . var.file . ":" . var.line)
  return var
endfunction


" Destroyer of the breakpoint. It just sends commands to debugger and destroys
" sign, but you should manually remove it from breakpoints array
function! s:Breakpoint.delete() dict
  call self._unset_sign()
  call self._send_delete_to_debugger()
endfunction


" Add condition to breakpoint. If server is not running, just store it, it
" will be evaluated after starting the server
function! s:Breakpoint.add_condition(condition) dict
  let self.condition = a:condition
  if has_key(g:RubyDebugger, 'server') && g:RubyDebugger.server.is_running() && has_key(self, 'debugger_id')
    call g:RubyDebugger.queue.add(self.condition_command())
  endif
endfunction



" Send adding breakpoint message to debugger, if it is run
function! s:Breakpoint.send_to_debugger() dict
  if has_key(g:RubyDebugger, 'server') && g:RubyDebugger.server.is_running()
    call g:RubyDebugger.queue.add(self.command())
  endif
endfunction


" Command for setting breakpoint (e.g.: 'break /path/to/file:23')
function! s:Breakpoint.command() dict
  return 'break ' . self.file . ':' . self.line
endfunction


" Command for adding condition to breakpoin (e.g.: 'condition 1 x>5')
function! s:Breakpoint.condition_command() dict
  return 'condition ' . self.debugger_id . ' ' . self.condition
endfunction


" Find and return breakpoint under cursor
function! s:Breakpoint.get_selected() dict
  let line = getline(".") 
  let match = matchlist(line, '^\(\d\+\)') 
  let id = get(match, 1)
  let breakpoints = filter(copy(g:RubyDebugger.breakpoints), "v:val.id == " . id)
  if !empty(breakpoints)
    return breakpoints[0]
  else
    return {}
  endif
endfunction


" Output format for Breakpoints Window
function! s:Breakpoint.render() dict
  let output = self.id . " " . (exists("self.debugger_id") ? self.debugger_id : '') . " " . self.file . ":" . self.line
  if exists("self.condition")
    let output .= " " . self.condition
  endif
  return output . "\n"
endfunction


" Open breakpoint in existed/new window
function! s:Breakpoint.open() dict
  call s:jump_to_file(self.file, self.line)
endfunction


" ** Private methods


function! s:Breakpoint._set_sign() dict
  if has("signs")
    exe ":sign place " . self.id . " line=" . self.line . " name=breakpoint file=" . self.file
  endif
endfunction


function! s:Breakpoint._unset_sign() dict
  if has("signs")
    exe ":sign unplace " . self.id
  endif
endfunction


function! s:Breakpoint._log(string) dict
  call g:RubyDebugger.logger.put(a:string)
endfunction


" Send deleting breakpoint message to debugger, if it is run
" (e.g.: 'delete 5')
function! s:Breakpoint._send_delete_to_debugger() dict
  if has_key(g:RubyDebugger, 'server') && g:RubyDebugger.server.is_running()
    let message = 'delete ' . self.debugger_id
    call g:RubyDebugger.queue.add(message)
  endif
endfunction


" *** Breakpoint class (end)

" *** Exception class (start)
" These are ruby exceptions we catch with 'catch Exception' command
" (:RdbCatch)

let s:Exception = { }

" ** Public methods

" Constructor of new exception.
function! s:Exception.new(name)
  let var = copy(self)
  let var.name = a:name
  call var._log("Trying to set exception: " . var.name)
  call g:RubyDebugger.queue.add(var.command())
  return var
endfunction


" Command for setting exception (e.g.: 'catch NameError')
function! s:Exception.command() dict
  return 'catch ' . self.name
endfunction


" Output format for Breakpoints Window
function! s:Exception.render() dict
  return self.name
endfunction


" ** Private methods


function! s:Exception._log(string) dict
  call g:RubyDebugger.logger.put(a:string)
endfunction


" *** Exception class (end)




" *** Frame class (start)

let s:Frame = { }

" ** Public methods

" Constructor of new frame. 
" Create new frame and set sign to it.
function! s:Frame.new(attrs)
  let var = copy(self)
  let var.no = a:attrs.no
  let var.file = a:attrs.file
  let var.line = a:attrs.line
  if has_key(a:attrs, 'current')
    let var.current = (a:attrs.current == 'true')
  else
    let var.current = 0
  endif
  "let s:sign_id += 1
  "let var.sign_id = s:sign_id
  "call var._set_sign()
  return var
endfunction


" Find and return frame under cursor
function! s:Frame.get_selected() dict
  let line = getline(".") 
  let match = matchlist(line, '^\(\d\+\)') 
  let no = get(match, 1)
  let frames = filter(copy(g:RubyDebugger.frames), "v:val.no == " . no)
  if !empty(frames)
    return frames[0]
  else
    return {}
  endif
endfunction


" Output format for Frame Window
function! s:Frame.render() dict
  return self.no . (self.current ? ' Current' : ''). " " . self.file . ":" . self.line . "\n"
endfunction


" Open frame in existed/new window
function! s:Frame.open() dict
  call s:jump_to_file(self.file, self.line)
endfunction


" ** Private methods

function! s:Frame._log(string) dict
  call g:RubyDebugger.logger.put(a:string)
endfunction


function! s:Frame._set_sign() dict
  if has("signs")
    exe ":sign place " . self.sign_id . " line=" . self.line . " name=frame file=" . self.file
  endif
endfunction


function! s:Frame._unset_sign() dict
  if has("signs")
    exe ":sign unplace " . self.sign_id
  endif
endfunction


" *** Frame class (end)



" *** Server class (start)

let s:Server = {}

" ** Public methods

" Constructor of new server. Just inits it, not runs
function! s:Server.new(hostname, rdebug_port, debugger_port, runtime_dir, tmp_file, output_file) dict
  let var = copy(self)
  let var.hostname = a:hostname
  let var.rdebug_port = a:rdebug_port
  let var.debugger_port = a:debugger_port
  let var.runtime_dir = a:runtime_dir
  let var.tmp_file = a:tmp_file
  let var.output_file = a:output_file
  return var
endfunction


" Start the server. It will kill any listeners on given ports before.
function! s:Server.start(script) dict
  call self._stop_server(self.rdebug_port)
  call self._stop_server(self.debugger_port)
  " Remove leading and trailing quotes
  let script_name = substitute(a:script, "\\(^['\"]\\|['\"]$\\)", '', 'g')
  let rdebug = 'rdebug-ide -p ' . self.rdebug_port . ' -- ' . script_name
  let os = has("win32") || has("win64") ? 'win' : 'posix'
  " Example - ruby ~/.vim/bin/ruby_debugger.rb 39767 39768 vim VIM /home/anton/.vim/tmp/ruby_debugger posix
  let debugger_parameters = ' ' . self.hostname . ' ' . self.rdebug_port . ' ' . self.debugger_port . ' ' . g:ruby_debugger_progname . ' ' . v:servername . ' "' . self.tmp_file . '" ' . os

  " Start in background
  if has("win32") || has("win64")
    silent exe '! start ' . rdebug
    let debugger = 'ruby "' . expand(self.runtime_dir . "/bin/ruby_debugger.rb") . '"' . debugger_parameters
    silent exe '! start ' . debugger
  else
    call system(rdebug . ' > ' . self.output_file . ' 2>&1 &')
    let debugger = 'ruby ' . expand(self.runtime_dir . "/bin/ruby_debugger.rb") . debugger_parameters
    call system(debugger. ' &')
  endif

  " Set PIDs of processes
  let self.rdebug_pid = self._get_pid(self.rdebug_port, 1)
  let self.debugger_pid = self._get_pid(self.debugger_port, 1)

  call g:RubyDebugger.logger.put("Start debugger")
endfunction  


" Kill servers and empty PIDs
function! s:Server.stop() dict
  call self._kill_process(self.rdebug_pid)
  call self._kill_process(self.debugger_pid)
  let self.rdebug_pid = ""
  let self.debugger_pid = ""
endfunction


" Return 1 if processes with set PID exist.
function! s:Server.is_running() dict
  return (self._get_pid(self.rdebug_port, 0) =~ '^\d\+$') && (self._get_pid(self.debugger_port, 0) =~ '^\d\+$')
endfunction


" ** Private methods


" Get PID of process, that listens given port on given host. If must_get_pid
" parameter is true, it will try to get PID for 20 seconds.
function! s:Server._get_pid(port, must_get_pid)
  let attempt = 0
  let pid = self._get_pid_attempt(a:port)
  while a:must_get_pid && pid == "" && attempt < 2000
    sleep 10m
    let attempt += 1
    let pid = self._get_pid_attempt(a:port)
  endwhile
  return pid
endfunction


" Just try to get PID of process and return empty string if it was
" unsuccessful
function! s:Server._get_pid_attempt(port)
  if has("win32") || has("win64")
    let netstat = system("netstat -anop tcp")
    let pid_match = matchlist(netstat, ':' . a:port . '\s.\{-}LISTENING\s\+\(\d\+\)')
    let pid = len(pid_match) > 0 ? pid_match[1] : ""
  elseif executable('lsof')
    let pid = system("lsof -i tcp:" . a:port . " | grep LISTEN | awk '{print $2}'")
    let pid = substitute(pid, '\n', '', '')
  else
    let pid = ""
  endif
  return pid
endfunction


" Kill listener of given host/port
function! s:Server._stop_server(port) dict
  let pid = self._get_pid(a:port, 0)
  if pid =~ '^\d\+$'
    call self._kill_process(pid)
  endif
endfunction


" Kill process with given PID
function! s:Server._kill_process(pid) dict
  echo "Killing server with pid " . a:pid
  call system("ruby -e 'Process.kill(9," . a:pid . ")'")
  sleep 100m
  call self._log("Killed server with pid: " . a:pid)
endfunction


function! s:Server._log(string) dict
  call g:RubyDebugger.logger.put(a:string)
endfunction


" *** Server class (end)



" *** Creating instances (start)

if !exists("g:ruby_debugger_fast_sender")
  let g:ruby_debugger_fast_sender = 0
endif
" This variable allows to use built-in Ruby (see ':help ruby' and s:send_message_to_debugger function)
if !exists("g:ruby_debugger_builtin_sender")
  if has("ruby")
    let g:ruby_debugger_builtin_sender = 1
  else
    let g:ruby_debugger_builtin_sender = 0
  endif
endif
if !exists("g:ruby_debugger_spec_path")
  let g:ruby_debugger_spec_path = '/usr/bin/spec'
endif
if !exists("g:ruby_debugger_cucumber_path")
  let g:ruby_debugger_cucumber_path = '/usr/bin/cucumber'
endif
if !exists("g:ruby_debugger_progname")
  let g:ruby_debugger_progname = v:progname
endif

" Creating windows
let s:variables_window = s:WindowVariables.new("variables", "Variables_Window")
let s:breakpoints_window = s:WindowBreakpoints.new("breakpoints", "Breakpoints_Window")
let s:frames_window = s:WindowFrames.new("frames", "Backtrace_Window")

" Init logger. The plugin logs all its actions. If you have some troubles,
" this file can help
let s:logger_file = s:runtime_dir . '/tmp/ruby_debugger_log'
let RubyDebugger.logger = s:Logger.new(s:logger_file)
let s:variables_window.logger = RubyDebugger.logger
let s:breakpoints_window.logger = RubyDebugger.logger
let s:frames_window.logger = RubyDebugger.logger

" *** Creating instances (end)

