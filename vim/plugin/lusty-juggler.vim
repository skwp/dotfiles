"    Copyright: Copyright (C) 2008-2011 Stephen Bach
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               lusty-juggler.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damages
"               resulting from the use of this software.
"
" Name Of File: lusty-juggler.vim
"  Description: Dynamic Buffer Switcher Vim Plugin
"   Maintainer: Stephen Bach <this-file@sjbach.com>
" Contributors: Juan Frias, Bartosz Leper, Marco Barberis, Vincent Driessen,
"               Martin Wache, Johannes Holzfuß, Adam Rutkowski, Carlo Teubner,
"               lilydjwg, Leonid Shevtsov, Giuseppe Rota
"
" Release Date: April 29, 2011
"      Version: 1.3
"
"        Usage:
"                 <Leader>lj  - Opens the buffer juggler.
"
"               You can also use this command:
"
"                 ":LustyJuggler"
"
"               (Personally, I map this to ,j)
"
"               When launched, the command bar at bottom is replaced with a
"               new bar showing the names of currently-opened buffers in
"               most-recently-used order.
"
"               The buffers are mapped to these keys:
"
"                   1st|2nd|3rd|4th|5th|6th|7th|8th|9th|10th
"                   ----------------------------------------
"                   a   s   d   f   g   h   j   k   l   ;
"                   1   2   3   4   5   6   7   8   9   0
"
"               So if you type "f" or "4", the fourth buffer name will be
"               highlighted and the bar will shift to center it as necessary
"               (and show more of the buffer names on the right).
"
"               If you want to switch to that buffer, press "f" or "4" again
"               or press "<ENTER>".  Alternatively, press one of the other
"               mapped keys to highlight another buffer.
"
"               To display the key with the name of the buffer, add one of
"               the following lines to your .vimrc:
"
"                 let g:LustyJugglerShowKeys = 'a'   (for alpha characters)
"                 let g:LustyJugglerShowKeys = 1     (for digits)
"
"               To cancel the juggler, press any of "q", "<ESC>", "<C-c",
"               "<BS>", "<Del>", or "<C-h>".
"
"               LustyJuggler can act very much like <A-Tab> window switching.
"               To enable this mode, add the following line to your .vimrc:
"
"                 let g:LustyJugglerAltTabMode = 1
"
"               Then, given the following mapping:
"
"                 noremap <silent> <A-s> :LustyJuggler<CR>
"
"               Pressing "<A-s>" will launch the LustyJuggler with the
"               previous buffer highlighted. Typing "<A-s>" again will cycle
"               to the next buffer (in most-recently used order), and
"               "<ENTER>" will open the highlighted buffer.  For example, the
"               sequence "<A-s><Enter>" will open the previous buffer, and
"               "<A-s><A-s><Enter>" will open the buffer used just before the
"               previous buffer, and so on.
"
"        Bonus: This plugin also includes the following command, which will
"               immediately switch to your previously used buffer:
"
"                 ":LustyJugglePrevious"
"
"               This is similar to the ":b#" command, but accounts for the
"               common situation where the previously used buffer (#) has
"               been killed and is thus inaccessible.  In that case, it will
"               instead switch to the buffer used before that one (and on down
"               the line if that buffer has been killed too).
"
"
" Install Details:
"
" Copy this file into $HOME/.vim/plugin directory so that it will be sourced
" on startup automatically.
"
" Note! This plugin requires Vim be compiled with Ruby interpretation.  If you
" don't know if your build of Vim has this functionality, you can check by
" running "vim --version" from the command line and looking for "+ruby".
" Alternatively, just try sourcing this script.
"
" If your version of Vim does not have "+ruby" but you would still like to
" use this plugin, you can fix it.  See the "Check for Ruby functionality"
" comment below for instructions.
"
" If you are using the same Vim configuration and plugins for multiple
" machines, some of which have Ruby and some of which don't, you may want to
" turn off the "Sorry, LustyJuggler requires ruby" warning.  You can do so
" like this (in .vimrc):
"
"   let g:LustyJugglerSuppressRubyWarning = 1
"
"
" Contributing:
"
" Patches and suggestions welcome.  Note: lusty-juggler.vim is a generated
" file; if you'd like to submit a patch, check out the Github development
" repository:
"
"    http://github.com/sjbach/lusty
"
"
" GetLatestVimScripts: 2050 1 :AutoInstall: lusty-juggler.vim
"
" TODO:
" - Add TAB recognition back.
" - Add option to open buffer immediately when mapping is pressed (but not
"   release the juggler until the confirmation press).
" - Have the delimiter character settable.
"   - have colours settable?

" Exit quickly when already loaded.
if exists("g:loaded_lustyjuggler")
  finish
endif

if &compatible
  echohl ErrorMsg
  echo "LustyJuggler is not designed to run in &compatible mode;"
  echo "To use this plugin, first disable vi-compatible mode like so:\n"

  echo "   :set nocompatible\n"

  echo "Or even better, just create an empty .vimrc file."
  echohl none
  finish
endif

if exists("g:FuzzyFinderMode.TextMate")
  echohl WarningMsg
  echo "Warning: LustyJuggler detects the presence of fuzzyfinder_textmate;"
  echo "that plugin often interacts poorly with other Ruby plugins."
  echo "If LustyJuggler gives you an error, you can probably fix it by"
  echo "renaming fuzzyfinder_textmate.vim to zzfuzzyfinder_textmate.vim so"
  echo "that it is last in the load order."
  echohl none
endif

" Check for Ruby functionality.
if !has("ruby")
  if !exists("g:LustyExplorerSuppressRubyWarning") ||
      \ g:LustyExplorerSuppressRubyWarning == "0"
  if !exists("g:LustyJugglerSuppressRubyWarning") ||
      \ g:LustyJugglerSuppressRubyWarning == "0"
    echohl ErrorMsg
    echon "Sorry, LustyJuggler requires ruby.  "
    echon "Here are some tips for adding it:\n"

    echo "Debian / Ubuntu:"
    echo "    # apt-get install vim-ruby\n"

    echo "Fedora:"
    echo "    # yum install vim-enhanced\n"

    echo "Gentoo:"
    echo "    # USE=\"ruby\" emerge vim\n"

    echo "FreeBSD:"
    echo "    # pkg_add -r vim+ruby\n"

    echo "Windows:"
    echo "    1. Download and install Ruby from here:"
    echo "       http://www.ruby-lang.org/"
    echo "    2. Install a Vim binary with Ruby support:"
    echo "       http://segfault.hasno.info/vim/gvim72.zip\n"

    echo "Manually (including Cygwin):"
    echo "    1. Install Ruby."
    echo "    2. Download the Vim source package (say, vim-7.0.tar.bz2)"
    echo "    3. Build and install:"
    echo "         # tar -xvjf vim-7.0.tar.bz2"
    echo "         # ./configure --enable-rubyinterp"
    echo "         # make && make install\n"

    echo "(If you just wish to stifle this message, set the following option:"
    echo "  let g:LustyJugglerSuppressRubyWarning = 1)"
    echohl none
  endif
  endif
  finish
endif

let g:loaded_lustyjuggler = "yep"

" Commands.
command LustyJuggler :call <SID>LustyJugglerStart()
command LustyJugglePrevious :call <SID>LustyJugglePreviousRun()

" Deprecated command names.
command JugglePrevious :call
  \ <SID>deprecated('JugglePrevious', 'LustyJugglePrevious')

function! s:deprecated(old, new)
  echohl WarningMsg
  echo ":" . a:old . " is deprecated; use :" . a:new . " instead."
  echohl none
endfunction


" Default mappings.
nmap <silent> <Leader>lj :LustyJuggler<CR>

" Vim-to-ruby function calls.
function! s:LustyJugglerStart()
  ruby LustyJ::profile() { $lusty_juggler.run }
endfunction

function! s:LustyJugglerKeyPressed(code_arg)
  ruby LustyJ::profile() { $lusty_juggler.key_pressed }
endfunction

function! s:LustyJugglerCancel()
  ruby LustyJ::profile() { $lusty_juggler.cleanup }
endfunction

function! s:LustyJugglePreviousRun()
  ruby LustyJ::profile() { $lj_buffer_stack.juggle_previous }
endfunction

" Setup the autocommands that handle buffer MRU ordering.
augroup LustyJuggler
  autocmd!
  autocmd BufEnter * ruby LustyJ::profile() { $lj_buffer_stack.push }
  autocmd BufDelete * ruby LustyJ::profile() { $lj_buffer_stack.pop }
  autocmd BufWipeout * ruby LustyJ::profile() { $lj_buffer_stack.pop }
augroup End

" Used to work around a flaw in Vim's ruby bindings.
let s:maparg_holder = 0
let s:maparg_dict_holder = { }

ruby << EOF

require 'pathname'

$LUSTY_PROFILING = false

if $LUSTY_PROFILING
  require 'rubygems'
  require 'ruby-prof'
end


module VIM

  unless const_defined? "MOST_POSITIVE_INTEGER"
    MOST_POSITIVE_INTEGER = 2**(32 - 1) - 2  # Vim ints are signed 32-bit.
  end

  def self.zero?(var)
    # In Vim 7.2 and older, VIM::evaluate returns Strings for boolean
    # expressions; in later versions, Fixnums.
    case var
    when String
      var == "0"
    when Fixnum
      var == 0
    else
      LustyJ::assert(false, "unexpected type: #{var.class}")
    end
  end

  def self.nonzero?(var)
    not zero?(var)
  end

  def self.evaluate_bool(var)
    nonzero? evaluate(var)
  end

  def self.exists?(s)
    nonzero? evaluate("exists('#{s}')")
  end

  def self.has_syntax?
    nonzero? evaluate('has("syntax")')
  end

  def self.has_ext_maparg?
    # The 'dict' parameter to mapargs() was introduced in Vim 7.3.32
    nonzero? evaluate('v:version > 703 || (v:version == 703 && has("patch32"))')
  end

  def self.columns
    evaluate("&columns").to_i
  end

  def self.lines
    evaluate("&lines").to_i
  end

  def self.getcwd
    evaluate("getcwd()")
  end

  def self.bufname(i)
    if evaluate_bool("empty(bufname(#{i}))")
      "<Unknown #{i}>"
    else
      evaluate("bufname(#{i})")
    end
  end

  def self.single_quote_escape(s)
    # Everything in a Vim single-quoted string is literal, except single
    # quotes.  Single quotes are escaped by doubling them.
    s.gsub("'", "''")
  end

  def self.filename_escape(s)
    # Escape slashes, open square braces, spaces, sharps, double quotes and
    # percent signs.
    s.gsub(/\\/, '\\\\\\').gsub(/[\[ #"%]/, '\\\\\0')
  end

  def self.regex_escape(s)
    s.gsub(/[\]\[.~"^$\\*]/,'\\\\\0')
  end

  class Buffer
    def modified?
      VIM::nonzero? VIM::evaluate("getbufvar(#{number()}, '&modified')")
    end

    def listed?
      VIM::nonzero? VIM::evaluate("getbufvar(#{number()}, '&buflisted')")
    end

    def self.obj_for_bufnr(n)
      # There's gotta be a better way to do this...
      (0..VIM::Buffer.count-1).each do |i|
        obj = VIM::Buffer[i]
        return obj if obj.number == n
      end

      return nil
    end
  end

  # Print with colours
  def self.pretty_msg(*rest)
    return if rest.length == 0
    return if rest.length % 2 != 0

    command "redraw"  # see :help echo-redraw
    i = 0
    while i < rest.length do
      command "echohl #{rest[i]}"
      command "echon '#{rest[i+1]}'"
      i += 2
    end

    command 'echohl None'
  end
end

# Hack for wide CJK characters.
if VIM::exists?("*strwidth")
  module VIM
    def self.strwidth(s)
      # strwidth() is defined in Vim 7.3.
      evaluate("strwidth('#{single_quote_escape(s)}')").to_i
    end
  end
else
  module VIM
    def self.strwidth(s)
      s.length
    end
  end
end


# Utility functions.
module LustyJ

  unless const_defined? "MOST_POSITIVE_FIXNUM"
    MOST_POSITIVE_FIXNUM = 2**(0.size * 8 -2) -1
  end

  def self.simplify_path(s)
    s = s.gsub(/\/+/, '/')  # Remove redundant '/' characters
    begin
      if s[0] == ?~
        # Tilde expansion - First expand the ~ part (e.g. '~' or '~steve')
        # and then append the rest of the path.  We can't just call
        # expand_path() or it'll throw on bad paths.
        s = File.expand_path(s.sub(/\/.*/,'')) + \
            s.sub(/^[^\/]+/,'')
      end

      if s == '/'
        # Special-case root so we don't add superfluous '/' characters,
        # as this can make Cygwin choke.
        s
      elsif ends_with?(s, File::SEPARATOR)
        File.expand_path(s) + File::SEPARATOR
      else
        dirname_expanded = File.expand_path(File.dirname(s))
        if dirname_expanded == '/'
          dirname_expanded + File.basename(s)
        else
          dirname_expanded + File::SEPARATOR + File.basename(s)
        end
      end
    rescue ArgumentError
      s
    end
  end

  def self.longest_common_prefix(paths)
    prefix = paths[0]
    paths.each do |path|
      for i in 0...prefix.length
        if path.length <= i or prefix[i] != path[i]
          prefix = prefix[0...i]
          prefix = prefix[0..(prefix.rindex('/') or -1)]
          break
        end
      end
    end

    prefix
  end

  def self.ready_for_read?(io)
    if io.respond_to? :ready?
      ready?
    else
      result = IO.select([io], nil, nil, 0)
      result && (result.first.first == io)
    end
  end

  def self.ends_with?(s1, s2)
    tail = s1[-s2.length, s2.length]
    tail == s2
  end

  def self.starts_with?(s1, s2)
    head = s1[0, s2.length]
    head == s2
  end

  def self.option_set?(opt_name)
    opt_name = "g:LustyExplorer" + opt_name
    VIM::evaluate_bool("exists('#{opt_name}') && #{opt_name} != '0'")
  end

  def self.profile
    # Profile (if enabled) and provide better
    # backtraces when there's an error.

    if $LUSTY_PROFILING
      if not RubyProf.running?
        RubyProf.measure_mode = RubyProf::WALL_TIME
        RubyProf.start
      else
        RubyProf.resume
      end
    end

    begin
      yield
    rescue Exception => e
      puts e
      puts e.backtrace
    end

    if $LUSTY_PROFILING and RubyProf.running?
      RubyProf.pause
    end
  end

  class AssertionError < StandardError ; end

  def self.assert(condition, message = 'assertion failure')
    raise AssertionError.new(message) unless condition
  end

  def self.d(s)
    # (Debug print)
    $stderr.puts s
  end
end


module LustyJ
class LustyJuggler
  private
    @@KEYS = { "a" => 1,
               "s" => 2,
               "d" => 3,
               "f" => 4,
               "g" => 5,
               "h" => 6,
               "j" => 7,
               "k" => 8,
               "l" => 9,
               ";" => 10,
               "1" => 1,
               "2" => 2,
               "3" => 3,
               "4" => 4,
               "5" => 5,
               "6" => 6,
               "7" => 7,
               "8" => 8,
               "9" => 9,
               "0" => 10 }

  public
    def initialize
      @running = false
      @last_pressed = nil
      @name_bar = NameBar.new
    end

    def run
      if $lj_buffer_stack.length <= 1
        VIM::pretty_msg("PreProc", "No other buffers")
        return
      end

      # If already running, highlight next buffer
      if @running and LustyJuggler::alt_tab_mode_active?
        @last_pressed = (@last_pressed % $lj_buffer_stack.length) + 1;
        print_buffer_list(@last_pressed)
        return
      end

      return if @running
      @running = true

      # Need to zero the timeout length or pressing 'g' will hang.
      @ruler = VIM::evaluate_bool("&ruler")
      @showcmd = VIM::evaluate_bool("&showcmd")
      @showmode = VIM::evaluate_bool("&showmode")
      @timeoutlen = VIM::evaluate("&timeoutlen")
      VIM::set_option 'timeoutlen=0'
      VIM::set_option 'noruler'
      VIM::set_option 'noshowcmd'
      VIM::set_option 'noshowmode'

      @key_mappings_map = Hash.new { |hash, k| hash[k] = [] }

      # Selection keys.
      @@KEYS.keys.each do |c|
        map_key(c, ":call <SID>LustyJugglerKeyPressed('#{c}')<CR>")
      end
      # Can't use '<CR>' as an argument to :call func for some reason.
      map_key("<CR>", ":call <SID>LustyJugglerKeyPressed('ENTER')<CR>")
      map_key("<Tab>", ":call <SID>LustyJugglerKeyPressed('TAB')<CR>")

      # Split opener keys
      map_key("v", ":call <SID>LustyJugglerKeyPressed('v')<CR>")
      map_key("b", ":call <SID>LustyJugglerKeyPressed('b')<CR>")

      # Left and Right keys
      map_key("<Esc>OD", ":call <SID>LustyJugglerKeyPressed('Left')<CR>")
      map_key("<Esc>OC", ":call <SID>LustyJugglerKeyPressed('Right')<CR>")
      map_key("<Left>",  ":call <SID>LustyJugglerKeyPressed('Left')<CR>")
      map_key("<Right>", ":call <SID>LustyJugglerKeyPressed('Right')<CR>")

      # Cancel keys.
      map_key("i", ":call <SID>LustyJugglerCancel()<CR>")
      map_key("q", ":call <SID>LustyJugglerCancel()<CR>")
      map_key("<Esc>", ":call <SID>LustyJugglerCancel()<CR>")
      map_key("<C-c>", ":call <SID>LustyJugglerCancel()<CR>")
      map_key("<BS>", ":call <SID>LustyJugglerCancel()<CR>")
      map_key("<Del>", ":call <SID>LustyJugglerCancel()<CR>")
      map_key("<C-h>", ":call <SID>LustyJugglerCancel()<CR>")

      @last_pressed = 2 if LustyJuggler::alt_tab_mode_active?
      print_buffer_list(@last_pressed)
    end

    def key_pressed()
      c = VIM::evaluate("a:code_arg")

      if @last_pressed.nil? and c == 'ENTER'
        cleanup()
      elsif @last_pressed and (@@KEYS[c] == @last_pressed or c == 'ENTER')
        choose(@last_pressed)
        cleanup()
      elsif @last_pressed and %w(v b).include?(c)
        c=='v' ? vsplit(@last_pressed) : hsplit(@last_pressed)
        cleanup()
      elsif c == 'Left'
        @last_pressed = (@last_pressed.nil?) ? 0 : (@last_pressed)
        @last_pressed = (@last_pressed - 1) < 1 ? $lj_buffer_stack.length : (@last_pressed - 1)
        print_buffer_list(@last_pressed)
      elsif c == 'Right'
        @last_pressed = (@last_pressed.nil?) ? 0 : (@last_pressed)
        @last_pressed = (@last_pressed + 1) > $lj_buffer_stack.length ? 1 : (@last_pressed + 1)
        print_buffer_list(@last_pressed)
      else
        @last_pressed = @@KEYS[c]
        print_buffer_list(@last_pressed)
      end
    end

    # Restore settings, mostly.
    def cleanup
      @last_pressed = nil

      VIM::set_option "timeoutlen=#{@timeoutlen}"
      VIM::set_option "ruler" if @ruler
      VIM::set_option "showcmd" if @showcmd
      VIM::set_option "showmode" if @showmode

      @@KEYS.keys.each do |c|
        unmap_key(c)
      end
      unmap_key("<CR>")
      unmap_key("<Tab>")

      unmap_key("v")
      unmap_key("b")

      unmap_key("i")
      unmap_key("q")
      unmap_key("<Esc>")
      unmap_key("<C-c>")
      unmap_key("<BS>")
      unmap_key("<Del>")
      unmap_key("<C-h>")
      unmap_key("<Esc>OC")
      unmap_key("<Esc>OD")
      unmap_key("<Left>")
      unmap_key("<Right>")

      @running = false
      VIM::message ''
      VIM::command 'redraw'  # Prevents "Press ENTER to continue" message.
    end

  private
    def self.alt_tab_mode_active?
       return (VIM::exists?("g:LustyJugglerAltTabMode") and
               VIM::evaluate("g:LustyJugglerAltTabMode").to_i != 0)
    end

    def print_buffer_list(highlighted_entry = nil)
      # If the user pressed a key higher than the number of open buffers,
      # highlight the highest (see also BufferStack.num_at_pos()).

      @name_bar.selected_buffer = \
        if highlighted_entry
          # Correct for zero-based array.
          [highlighted_entry, $lj_buffer_stack.length].min - 1
        else
          nil
        end

      @name_bar.print
    end

    def choose(i)
      buf = $lj_buffer_stack.num_at_pos(i)
      VIM::command "b #{buf}"
    end
    
    def vsplit(i)
      buf = $lj_buffer_stack.num_at_pos(i)
      VIM::command "vert sb #{buf}"
    end
    
    def hsplit(i)
      buf = $lj_buffer_stack.num_at_pos(i)
      VIM::command "sb #{buf}"
    end

    def map_key(key, action)
      ['n','s','x','o','i','c','l'].each do |mode|
        VIM::command "let s:maparg_holder = maparg('#{key}', '#{mode}')"
        if VIM::evaluate_bool("s:maparg_holder != ''")
          orig_rhs = VIM::evaluate("s:maparg_holder")
          if VIM::has_ext_maparg?
            VIM::command "let s:maparg_dict_holder = maparg('#{key}', '#{mode}', 0, 1)"
            nore    = VIM::evaluate_bool("s:maparg_dict_holder['noremap']") ? 'nore'      : ''
            silent  = VIM::evaluate_bool("s:maparg_dict_holder['silent']")  ? ' <silent>' : ''
            expr    = VIM::evaluate_bool("s:maparg_dict_holder['expr']")    ? ' <expr>'   : ''
            buffer  = VIM::evaluate_bool("s:maparg_dict_holder['buffer']")  ? ' <buffer>' : ''
            restore_cmd = "#{mode}#{nore}map#{silent}#{expr}#{buffer} #{key} #{orig_rhs}"
          else
            nore = LustyJ::starts_with?(orig_rhs, '<Plug>') ? '' : 'nore'
            restore_cmd = "#{mode}#{nore}map <silent> #{key} #{orig_rhs}"
          end
          @key_mappings_map[key] << [ mode, restore_cmd ]
        end
        VIM::command "#{mode}noremap <silent> #{key} #{action}"
      end
    end

    def unmap_key(key)
      #first, unmap lusty_juggler's maps
      ['n','s','x','o','i','c','l'].each do |mode|
        VIM::command "#{mode}unmap <silent> #{key}"
      end

      if @key_mappings_map.has_key?(key)
        @key_mappings_map[key].each do |a|
          mode, restore_cmd = *a
          # for mappings that have on the rhs \|, the \ is somehow stripped
          restore_cmd.gsub!("|", "\\|")
          VIM::command restore_cmd
        end
      end
    end
end
end


# An item (delimiter/separator or buffer name) on the NameBar.
module LustyJ
class BarItem
  def initialize(str, color)
    @str = str
    @color = color
  end

  def length
    @str.length
  end

  def pretty_print_input
    [@color, @str]
  end

  def [](*rest)
    return BarItem.new(@str[*rest], @color)
  end

  def self.full_length(array)
    if array
      array.inject(0) { |sum, el| sum + el.length }
    else
      0
    end
  end
end

class BufferItem < BarItem
  def initialize(str, highlighted)
    @str = str
    @highlighted = highlighted
    destructure()
  end

  def [](*rest)
    return BufferItem.new(@str[*rest], @highlighted)
  end

  def pretty_print_input
    @array
  end

  private
    @@BUFFER_COLOR = "PreProc"
    #@@BUFFER_COLOR = "None"
    @@DIR_COLOR = "Directory"
    @@SLASH_COLOR = "Function"
    @@HIGHLIGHTED_COLOR = "Question"

    # Breakdown the string to colourize each part.
    def destructure
      if @highlighted
        buf_color = @@HIGHLIGHTED_COLOR
        dir_color = @@HIGHLIGHTED_COLOR
        slash_color = @@HIGHLIGHTED_COLOR
      else
        buf_color = @@BUFFER_COLOR
        dir_color = @@DIR_COLOR
        slash_color = @@SLASH_COLOR
      end

      pieces = @str.split(File::SEPARATOR, -1)

      @array = []
      @array << dir_color
      @array << pieces.shift
      pieces.each { |piece|
        @array << slash_color
        @array << File::SEPARATOR
        @array << dir_color
        @array << piece
      }

      # Last piece is the actual name.
      @array[-2] = buf_color
    end
end

class SeparatorItem < BarItem
  public
    def initialize
      super(@@TEXT, @@COLOR)
    end

  private
    @@TEXT = "|"
    #@@COLOR = "NonText"
    @@COLOR = "None"
end

class LeftContinuerItem < BarItem
  public
    def initialize
      super(@@TEXT, @@COLOR)
    end

    def self.length
      @@TEXT.length
    end

  private
    @@TEXT = "<"
    @@COLOR = "NonText"
end

class RightContinuerItem < BarItem
  public
    def initialize
      super(@@TEXT, @@COLOR)
    end

    def self.length
      @@TEXT.length
    end

  private
    @@TEXT = ">"
    @@COLOR = "NonText"
end

end


# A one-line display of the open buffers, appearing in the command display.
module LustyJ
class NameBar
  public
    def initialize
      @selected_buffer = nil
    end

    attr_writer :selected_buffer

    def print
      items = create_items()

      selected_item = \
        if @selected_buffer
          # Account for the separators we've added.
          [@selected_buffer * 2, (items.length - 1)].min
        end

      clipped = clip(items, selected_item)
      NameBar.do_pretty_print(clipped)
    end

  private
    @@LETTERS = ["a", "s", "d", "f", "g", "h", "j", "k", "l", ";"]


    def create_items
      names = $lj_buffer_stack.names(10)

      items = names.inject([]) { |array, name|
        key = if VIM::exists?("g:LustyJugglerShowKeys")
                case VIM::evaluate("g:LustyJugglerShowKeys").to_s
                when /[[:alpha:]]/
                  @@LETTERS[array.size / 2] + ":"
                when /[[:digit:]]/
                  "#{((array.size / 2) + 1) % 10}:"
                else
                  ""
                end
              else
                ""
              end

        array << BufferItem.new("#{key}#{name}",
                            (@selected_buffer and \
                             name == names[@selected_buffer]))
        array << SeparatorItem.new
      }
      items.pop   # Remove last separator.

      return items
    end

    # Clip the given array of items to the available display width.
    def clip(items, selected)
      # This function is pretty hard to follow...

      # Note: Vim gives the annoying "Press ENTER to continue" message if we
      # use the full width.
      columns = VIM::columns() - 1

      if BarItem.full_length(items) <= columns
        return items
      end

      selected = 0 if selected.nil?
      half_displayable_len = columns / 2

      # The selected buffer is excluded since it's basically split between
      # the sides.
      left_len = BarItem.full_length items[0, selected - 1]
      right_len = BarItem.full_length items[selected + 1, items.length - 1]

      right_justify = (left_len > half_displayable_len) and \
                      (right_len < half_displayable_len)

      selected_str_half_len = (items[selected].length / 2) + \
                              (items[selected].length % 2 == 0 ? 0 : 1)

      if right_justify
        # Right justify the bar.
        first_layout = self.method :layout_right
        second_layout = self.method :layout_left
        first_adjustment = selected_str_half_len
        second_adjustment = -selected_str_half_len
      else
        # Left justify (sort-of more likely).
        first_layout = self.method :layout_left
        second_layout = self.method :layout_right
        first_adjustment = -selected_str_half_len
        second_adjustment = selected_str_half_len
      end

      # Layout the first side.
      allocation = half_displayable_len + first_adjustment
      first_side, remainder = first_layout.call(items,
                                                selected,
                                                allocation)

      # Then layout the second side, also grabbing any unused space.
      allocation = half_displayable_len + \
                   second_adjustment + \
                   remainder
      second_side, remainder = second_layout.call(items,
                                                  selected,
                                                  allocation)

      if right_justify
        second_side + first_side
      else
        first_side + second_side
      end
    end

    # Clip the given array of items to the given space, counting downwards.
    def layout_left(items, selected, space)
      trimmed = []

      i = selected - 1
      while i >= 0
        m = items[i]
        if space > m.length
          trimmed << m
          space -= m.length
        elsif space > 0
          trimmed << m[m.length - (space - LeftContinuerItem.length), \
                       space - LeftContinuerItem.length]
          trimmed << LeftContinuerItem.new
          space = 0
        else
          break
        end
        i -= 1
      end

      return trimmed.reverse, space
    end

    # Clip the given array of items to the given space, counting upwards.
    def layout_right(items, selected, space)
      trimmed = []

      i = selected
      while i < items.length
        m = items[i]
        if space > m.length
          trimmed << m
          space -= m.length
        elsif space > 0
          trimmed << m[0, space - RightContinuerItem.length]
          trimmed << RightContinuerItem.new
          space = 0
        else
          break
        end
        i += 1
      end

      return trimmed, space
    end

    def NameBar.do_pretty_print(items)
      args = items.inject([]) { |array, item|
        array = array + item.pretty_print_input
      }

      VIM::pretty_msg *args
    end
end

end



# Maintain MRU ordering.
module LustyJ
class BufferStack
  public
    def initialize
      @stack = []

      (0..VIM::Buffer.count-1).each do |i|
        @stack << VIM::Buffer[i].number
      end
    end

    # Switch to the previous buffer (the one you were using before the
    # current one).  This is basically a smarter replacement for :b#,
    # accounting for the situation where your previous buffer no longer
    # exists.
    def juggle_previous
      buf = num_at_pos(2)
      VIM::command "b #{buf}"
    end

    def names(n = :all)
      # Get the last n buffer names by MRU.  Show only as much of
      # the name as necessary to differentiate between buffers of
      # the same name.
      cull!
      names = @stack.collect { |i| VIM::bufname(i) }.reverse
      if n != :all
        names = names[0,n]
      end
      shorten_paths(names)
    end

    def numbers(n = :all)
      # Get the last n buffer numbers by MRU.
      cull!
      numbers = @stack.reverse
      if n == :all
        numbers
      else
        numbers[0,n]
      end
    end

    def num_at_pos(i)
      cull!
      return @stack[-i] ? @stack[-i] : @stack.first
    end

    def length
      cull!
      return @stack.length
    end

    def push
      @stack.delete $curbuf.number
      @stack << $curbuf.number
    end

    def pop
      number = VIM::evaluate('bufnr(expand("<afile>"))')
      @stack.delete number
    end

  private
    def cull!
      # Remove empty and unlisted buffers.
      @stack.delete_if { |x|
        not (VIM::evaluate_bool("bufexists(#{x})") and
             VIM::evaluate_bool("getbufvar(#{x}, '&buflisted')"))
      }
    end

    # NOTE: very similar to Entry::compute_buffer_entries()
    def shorten_paths(buffer_names)
      # Shorten each buffer name by removing all path elements which are not
      # needed to differentiate a given name from other names.  This usually
      # results in only the basename shown, but if several buffers of the
      # same basename are opened, there will be more.

      # Group the buffers by common basename
      common_base = Hash.new { |hash, k| hash[k] = [] }
      buffer_names.each do |name|
        basename = Pathname.new(name).basename.to_s
        common_base[basename] << name
      end

      # Determine the longest common prefix for each basename group.
      basename_to_prefix = {}
      common_base.each do |k, names|
        if names.length > 1
          basename_to_prefix[k] = LustyJ::longest_common_prefix(names)
        end
      end

      # Shorten each buffer_name by removing the prefix.
      buffer_names.map { |name|
        base = Pathname.new(name).basename.to_s
        prefix = basename_to_prefix[base]
        prefix ? name[prefix.length..-1] \
               : base
      }
    end
end

end



$lusty_juggler = LustyJ::LustyJuggler.new
$lj_buffer_stack = LustyJ::BufferStack.new

EOF

" vim: set sts=2 sw=2:
