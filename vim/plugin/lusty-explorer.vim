"    Copyright: Copyright (C) 2007-2011 Stephen Bach
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               lusty-explorer.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damages
"               resulting from the use of this software.
"
" Name Of File: lusty-explorer.vim
"  Description: Dynamic Filesystem and Buffer Explorer Vim Plugin
"  Maintainers: Stephen Bach <this-file@sjbach.com>
"               Matt Tolton <matt-lusty-explorer@tolton.com>
" Contributors: Raimon Grau, Sergey Popov, Yuichi Tateno, Bernhard Walle,
"               Rajendra Badapanda, cho45, Simo Salminen, Sami Samhuri,
"               Matt Tolton, Björn Winckler, sowill, David Brown
"               Brett DiFrischia, Ali Asad Lotia, Kenneth Love, Ben Boeckel,
"               robquant, lilydjwg, Martin Wache, Johannes Holzfuß
"               Donald Curtis, Jan Zwiener, Giuseppe Rota, Toby O'Connell
"
" Release Date: April 29, 2011
"      Version: 4.1
"
"        Usage:
"                 <Leader>lf  - Opens the filesystem explorer.
"                 <Leader>lr  - Opens the filesystem explorer from the
"                               directory of the current file.
"                 <Leader>lb  - Opens the buffer explorer.
"                 <Leader>lg  - Opens the buffer grep, for searching through
"                               all loaded buffers
"
"               You can also use the commands:
"
"                 ":LustyFilesystemExplorer [optional-path]"
"                 ":LustyFilesystemExplorerFromHere"
"                 ":LustyBufferExplorer"
"                 ":LustyBufferGrep"
"
"               (Personally, I map these to ,f ,r ,b and ,g)
"
"               When launched, a new window appears at bottom presenting a
"               table of files/dirs or buffers, and in the status bar a
"               prompt:
"
"                 >>
"
"               As you type, the table updates for possible matches using a
"               fuzzy matching algorithm (or regex matching, in the case of
"               grep).  Special keys include:
"
"                 <Enter>  open selected match
"                 <Tab>    open selected match
"                 <Esc>    cancel
"                 <C-c>    cancel
"                 <C-g>    cancel
"
"                 <C-t>    open selected match in a new [t]ab
"                 <C-o>    open selected match in a new h[o]rizontal split
"                 <C-v>    open selected match in a new [v]ertical split
"
"                 <C-n>    select [n]ext match
"                 <C-p>    select [p]revious match
"                 <C-f>    select [f]orward one column
"                 <C-b>    select [b]ack one column
"
"                 <C-u>    clear prompt
"
"               Additional shortcuts for the filesystem explorer:
"
"                 <C-w>    ascend one directory at prompt
"                 <C-r>    [r]efresh directory contents
"                 <C-a>    open [a]ll files in current table
"                 <C-e>    create new buffer with the given name and path
"
" Filesystem Explorer:
"
"  - Directory contents are memoized.  (<C-r> to refresh.)
"  - You can recurse into and out of directories by typing the directory name
"    and a slash, e.g. "stuff/" or "../".
"  - Variable expansion, e.g. "$D" -> "/long/dir/path/".
"  - Tilde (~) expansion, e.g. "~/" -> "/home/steve/".
"  - Dotfiles are hidden by default, but are shown if the current search term
"    begins with a '.'.  To show these file at all times, set this option:
"
"       let g:LustyExplorerAlwaysShowDotFiles = 1
"
"  You can prevent certain files from appearing in the table with the
"  following variable:
"
"    set wildignore=*.o,*.fasl,CVS
"
"  The above will mask all object files, compiled lisp files, and
"  files/directories named CVS from appearing in the table.  Note that they
"  can still be opened by being named explicitly.
"
"  See :help 'wildignore' for more information.
"
" Buffer Explorer:
"
"  - Buffers are sorted first by fuzzy match and then by most-recently used.
"  - The currently active buffer is highlighted.
"
" Buffer Grep:
"
"  - Searches all loaded buffers.
"  - Uses Ruby-style regexes instead of Vim style.  This means:
"
"    - \b instead of \< or \> for beginning/end of word.
"    - (foo|bar) instead of \(foo\|bar\)
"    - {2,5} instead of \{2,5}
"    - + instead of \+
"    - Generally, fewer backslashes. :-)
"
"  - For now, searches are always case-insensitive.
"  - Matches from the previous grep are remembered upon relaunch;  clear with
"    <C-u>.
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
" turn off the "Sorry, LustyExplorer requires ruby" warning.  You can do so
" like this (in .vimrc):
"
"   let g:LustyExplorerSuppressRubyWarning = 1
"
"
" Contributing:
"
" Patches and suggestions welcome.  Note: lusty-explorer.vim is a generated
" file; if you'd like to submit a patch, check out the Github development
" repository:
"
"    http://github.com/sjbach/lusty
"
"
" GetLatestVimScripts: 1890 1 :AutoInstall: lusty-explorer.vim
"
" TODO:
" - when an edited file is in nowrap mode and the explorer is called while the
"   current window is scrolled to the right, name truncation occurs.
" - enable VimSwaps stuff
"   - set callback when pipe is ready for read and force refresh()
" - uppercase character should make matching case-sensitive
" - FilesystemGrep
" - C-jhkl navigation to highlight a file?

" Exit quickly when already loaded.
if exists("g:loaded_lustyexplorer")
  finish
endif

if &compatible
  echohl ErrorMsg
  echo "LustyExplorer is not designed to run in &compatible mode;"
  echo "To use this plugin, first disable vi-compatible mode like so:\n"

  echo "   :set nocompatible\n"

  echo "Or even better, just create an empty .vimrc file."
  echohl none
  finish
endif

if exists("g:FuzzyFinderMode.TextMate")
  echohl WarningMsg
  echo "Warning: LustyExplorer detects the presence of fuzzyfinder_textmate;"
  echo "that plugin often interacts poorly with other Ruby plugins."
  echo "If LustyExplorer gives you an error, you can probably fix it by"
  echo "renaming fuzzyfinder_textmate.vim to zzfuzzyfinder_textmate.vim so"
  echo "that it is last in the load order."
  echohl none
endif

" Check for Ruby functionality.
if !has("ruby") || version < 700
  if !exists("g:LustyExplorerSuppressRubyWarning") ||
      \ g:LustyExplorerSuppressRubyWarning == "0"
  if !exists("g:LustyJugglerSuppressRubyWarning") ||
      \ g:LustyJugglerSuppressRubyWarning == "0"
    echohl ErrorMsg
    echon "Sorry, LustyExplorer requires ruby.  "
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
    echo "         # make && make install"

    echo "(If you just wish to stifle this message, set the following option:"
    echo "  let g:LustyExplorerSuppressRubyWarning = 1)"
    echohl none
  endif
  endif
  finish
endif

if ! &hidden
  echohl WarningMsg
  echo "You are running with 'hidden' mode off.  LustyExplorer may"
  echo "sometimes emit error messages in this mode -- you should turn"
  echo "it on, like so:\n"

  echo "   :set hidden\n"

  echo "Even better, put this in your .vimrc file."
  echohl none
endif

let g:loaded_lustyexplorer = "yep"

" Commands.
command LustyBufferExplorer :call <SID>LustyBufferExplorerStart()
command -nargs=? LustyFilesystemExplorer :call <SID>LustyFilesystemExplorerStart("<args>")
command LustyFilesystemExplorerFromHere :call <SID>LustyFilesystemExplorerStart(expand("%:p:h"))
command LustyBufferGrep :call <SID>LustyBufferGrepStart()

" Deprecated command names.
command BufferExplorer :call
  \ <SID>deprecated('BufferExplorer', 'LustyBufferExplorer')
command FilesystemExplorer :call
  \ <SID>deprecated('FilesystemExplorer', 'LustyFilesystemExplorer')
command FilesystemExplorerFromHere :call
  \ <SID>deprecated('FilesystemExplorerFromHere',
  \                 'LustyFilesystemExplorerFromHere')

function! s:deprecated(old, new)
  echohl WarningMsg
  echo ":" . a:old . " is deprecated; use :" . a:new . " instead."
  echohl none
endfunction


" Default mappings.
nmap <silent> <Leader>lf :LustyFilesystemExplorer<CR>
nmap <silent> <Leader>lr :LustyFilesystemExplorerFromHere<CR>
nmap <silent> <Leader>lb :LustyBufferExplorer<CR>
nmap <silent> <Leader>lg :LustyBufferGrep<CR>

" Vim-to-ruby function calls.
function! s:LustyFilesystemExplorerStart(path)
  exec "ruby LustyE::profile() { $lusty_filesystem_explorer.run_from_path('".a:path."') }"
endfunction

function! s:LustyBufferExplorerStart()
  ruby LustyE::profile() { $lusty_buffer_explorer.run }
endfunction

function! s:LustyBufferGrepStart()
  ruby LustyE::profile() { $lusty_buffer_grep.run }
endfunction

function! s:LustyFilesystemExplorerCancel()
  ruby LustyE::profile() { $lusty_filesystem_explorer.cancel }
endfunction

function! s:LustyBufferExplorerCancel()
  ruby LustyE::profile() { $lusty_buffer_explorer.cancel }
endfunction

function! s:LustyBufferGrepCancel()
  ruby LustyE::profile() { $lusty_buffer_grep.cancel }
endfunction

function! s:LustyFilesystemExplorerKeyPressed(code_arg)
  ruby LustyE::profile() { $lusty_filesystem_explorer.key_pressed }
endfunction

function! s:LustyBufferExplorerKeyPressed(code_arg)
  ruby LustyE::profile() { $lusty_buffer_explorer.key_pressed }
endfunction

function! s:LustyBufferGrepKeyPressed(code_arg)
  ruby LustyE::profile() { $lusty_buffer_grep.key_pressed }
endfunction

" Setup the autocommands that handle buffer MRU ordering.
augroup LustyExplorer
  autocmd!
  autocmd BufEnter * ruby LustyE::profile() { $le_buffer_stack.push }
  autocmd BufDelete * ruby LustyE::profile() { $le_buffer_stack.pop }
  autocmd BufWipeout * ruby LustyE::profile() { $le_buffer_stack.pop }
augroup End

ruby << EOF

require 'pathname'
# For IO#ready -- but Cygwin doesn't have io/wait.
require 'io/wait' unless RUBY_PLATFORM =~ /cygwin/
# Needed for String#each_char in Ruby 1.8 on some platforms.
require 'jcode' unless "".respond_to? :each_char
# Needed for Array#each_slice in Ruby 1.8 on some platforms.
require 'enumerator' unless [].respond_to? :each_slice

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
      LustyE::assert(false, "unexpected type: #{var.class}")
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
module LustyE

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


# Mercury fuzzy matching algorithm, written by Matt Tolton.
#  based on the Quicksilver and LiquidMetal fuzzy matching algorithms
class Mercury
  public
    def self.score(string, abbrev)
      return self.new(string, abbrev).score()
    end

    def score()
      return @@SCORE_TRAILING if @abbrev.empty?
      return @@SCORE_NO_MATCH if @abbrev.length > @string.length

      raw_score = raw_score(0, 0, 0, false)
      return raw_score / @string.length
    end

    def initialize(string, abbrev)
      @string = string
      @lower_string = string.downcase()
      @abbrev = abbrev.downcase()
      @level = 0
      @branches = 0
    end

  private
    @@SCORE_NO_MATCH = 0.0 # do not change, this is assumed to be 0.0
    @@SCORE_EXACT_MATCH = 1.0
    @@SCORE_MATCH = 0.9
    @@SCORE_TRAILING = 0.7
    @@SCORE_TRAILING_BUT_STARTED = 0.80
    @@SCORE_BUFFER = 0.70
    @@SCORE_BUFFER_BUT_STARTED = 0.80

    @@BRANCH_LIMIT = 100

    #def raw_score(a, b, c, d)
    #  @level += 1
    #  puts "#{' ' * @level}#{a}, #{b}, #{c}, #{d}"
    #  ret = recurse_and_score(a, b, c, d)
    #  puts "#{' ' * @level}#{a}, #{b}, #{c}, #{d} -> #{ret}"
    #  @level -= 1
    #  return ret
    #end

    def raw_score(abbrev_idx, match_idx, score_idx, first_char_matched)
      index = @lower_string.index(@abbrev[abbrev_idx], match_idx)
      return 0.0 if index.nil?

      # TODO Instead of having two scores, should there be a sliding "match"
      # score based on the distance of the matched character to the beginning
      # of the string?
      if abbrev_idx == index
        score = @@SCORE_EXACT_MATCH
      else
        score = @@SCORE_MATCH
      end

      started = (index == 0 or first_char_matched)

      # If matching on a word boundary, score the characters since the last match
      if index > score_idx
        buffer_score = started ? @@SCORE_BUFFER_BUT_STARTED : @@SCORE_BUFFER
        if " \t/._-".include?(@string[index - 1])
          score += @@SCORE_MATCH
          score += buffer_score * ((index - 1) - score_idx)
        elsif @string[index] >= "A"[0] and @string[index] <= "Z"[0]
          score += buffer_score * (index - score_idx)
        end
      end

      if abbrev_idx + 1 == @abbrev.length
        trailing_score = started ? @@SCORE_TRAILING_BUT_STARTED : @@SCORE_TRAILING
        # We just matched the last character in the pattern
        score += trailing_score * (@string.length - (index + 1))
      else
        tail_score = raw_score(abbrev_idx + 1, index + 1, index + 1, started)
        return 0.0 if tail_score == 0.0
        score += tail_score
      end

      if @branches < @@BRANCH_LIMIT
        @branches += 1
        alternate = raw_score(abbrev_idx,
                              index + 1,
                              score_idx,
                              first_char_matched)
        #puts "#{' ' * @level}#{score}, #{alternate}"
        score = [score, alternate].max
      end

      return score
    end
end


module LustyE

# Abstract base class.
class Entry
  attr_accessor :full_name, :short_name, :label
  def initialize(full_name, short_name, label)
    @full_name = full_name
    @short_name = short_name
    @label = label
  end

  # NOTE: very similar to BufferStack::shorten_paths()
  def self.compute_buffer_entries()
    buffer_entries = []

    $le_buffer_stack.numbers.each do |n|
      o = VIM::Buffer.obj_for_bufnr(n)
      next if (o.nil? or not o.listed?)
      buffer_entries << self.new(o, n)
    end

    # Put the current buffer at the end of the list.
    buffer_entries << buffer_entries.shift

    # Shorten each buffer name by removing all path elements which are not
    # needed to differentiate a given name from other names.  This usually
    # results in only the basename shown, but if several buffers of the
    # same basename are opened, there will be more.

    # Group the buffers by common basename
    common_base = Hash.new { |hash, k| hash[k] = [] }
    buffer_entries.each do |entry|
      if entry.full_name
        basename = Pathname.new(entry.full_name).basename.to_s
        common_base[basename] << entry
      end
    end

    # Determine the longest common prefix for each basename group.
    basename_to_prefix = {}
    common_base.each do |base, entries|
      if entries.length > 1
        full_names = entries.map { |e| e.full_name }
        basename_to_prefix[base] = LustyE::longest_common_prefix(full_names)
      end
    end

    # Compute shortened buffer names by removing prefix, if possible.
    buffer_entries.each do |entry|
      full_name = entry.full_name

      short_name = if full_name.nil?
                     '[No Name]'
                   elsif LustyE::starts_with?(full_name, "scp://")
                     full_name
                   else
                     base = Pathname.new(full_name).basename.to_s
                     prefix = basename_to_prefix[base]

                     prefix ? full_name[prefix.length..-1] \
                            : base
                   end

      entry.short_name = short_name
    end

    buffer_entries
  end
end

# Used in FilesystemExplorer
class FilesystemEntry < Entry
  attr_accessor :current_score
  def initialize(label)
    super("::UNSET::", "::UNSET::", label)
    @current_score = 0.0
  end
end

# Used in BufferExplorer
class BufferEntry < Entry
  attr_accessor :vim_buffer, :mru_placement, :current_score
  def initialize(vim_buffer, mru_placement)
    super(vim_buffer.name, "::UNSET::", "::UNSET::")
    @vim_buffer = vim_buffer
    @mru_placement = mru_placement
    @current_score = 0.0
  end
end

# Used in BufferGrep
class GrepEntry < Entry
  attr_accessor :vim_buffer, :mru_placement, :line_number
  def initialize(vim_buffer, mru_placement)
    super(vim_buffer.name, "::UNSET::", "::UNSET::")
    @vim_buffer = vim_buffer
    @mru_placement = mru_placement
    @line_number = 0
  end
end

end


# Abstract base class; extended as BufferExplorer, FilesystemExplorer
module LustyE
class Explorer
  public
    def initialize
      @settings = SavedSettings.new
      @display = Display.new title()
      @prompt = nil
      @current_sorted_matches = []
      @running = false
    end

    def run
      return if @running

      @settings.save
      @running = true
      @calling_window = $curwin
      @saved_alternate_bufnum = if VIM::evaluate_bool("expand('#') == ''")
                                  nil
                                else
                                  VIM::evaluate("bufnr(expand('#'))")
                                end
      create_explorer_window()
      refresh(:full)
    end

    def key_pressed()
      # Grab argument from the Vim function.
      i = VIM::evaluate("a:code_arg").to_i
      refresh_mode = :full

      case i
        when 32..126          # Printable characters
          c = i.chr
          @prompt.add! c
          @selected_index = 0
        when 8                # Backspace/Del/C-h
          @prompt.backspace!
          @selected_index = 0
        when 9, 13            # Tab and Enter
          choose(:current_tab)
        when 23               # C-w (delete 1 dir backward)
          @prompt.up_one_dir!
          @selected_index = 0
        when 14               # C-n (select next)
          @selected_index = \
            if @current_sorted_matches.size.zero?
              0
            else
              (@selected_index + 1) % @current_sorted_matches.size
            end
          refresh_mode = :no_recompute
        when 16               # C-p (select previous)
          @selected_index = \
            if @current_sorted_matches.size.zero?
              0
            else
              (@selected_index - 1) % @current_sorted_matches.size
            end
          refresh_mode = :no_recompute
        when 6                # C-f (select right)
          @selected_index = \
            if @row_count.nil? || @row_count.zero?
              0
            else
              columns = \
                (@current_sorted_matches.size.to_f / @row_count.to_f).ceil
              cur_column = @selected_index / @row_count
              cur_row = @selected_index % @row_count
              new_column = (cur_column + 1) % columns
              if (new_column + 1) * (cur_row + 1) > @current_sorted_matches.size
                new_column = 0
              end
              new_column * @row_count + cur_row
            end
          refresh_mode = :no_recompute
        when 2                # C-b (select left)
          @selected_index = \
            if @row_count.nil? || @row_count.zero?
              0
            else
              columns = \
                (@current_sorted_matches.size.to_f / @row_count.to_f).ceil
              cur_column = @selected_index / @row_count
              cur_row = @selected_index % @row_count
              new_column = (cur_column - 1) % columns
              if (new_column + 1) * (cur_row + 1) > @current_sorted_matches.size
                new_column = columns - 2
              end
              new_column * @row_count + cur_row
            end
          refresh_mode = :no_recompute
        when 15               # C-o choose in new horizontal split
          choose(:new_split)
        when 20               # C-t choose in new tab
          choose(:new_tab)
        when 21               # C-u clear prompt
          @prompt.clear!
          @selected_index = 0
        when 22               # C-v choose in new vertical split
          choose(:new_vsplit)
      end

      refresh(refresh_mode)
    end

    def cancel
      if @running
        cleanup()
        # fix alternate file
        if @saved_alternate_bufnum
          cur = $curbuf
          VIM::command "silent b #{@saved_alternate_bufnum}"
          VIM::command "silent b #{cur.number}"
        end

        if $LUSTY_PROFILING
          outfile = File.new('lusty-explorer-rbprof.html', 'a')
          #RubyProf::CallTreePrinter.new(RubyProf.stop).print(outfile)
          RubyProf::GraphHtmlPrinter.new(RubyProf.stop).print(outfile)
        end
      end
    end

  private
    def refresh(mode)
      return if not @running

      if mode == :full
        @current_sorted_matches = compute_sorted_matches()
      end

      on_refresh()
      highlight_selected_index() if VIM::has_syntax?
      @row_count = @display.print @current_sorted_matches.map { |x| x.label }
      @prompt.print Display.max_width
    end

    def create_explorer_window
      # Trim out the "::" in "LustyE::FooExplorer"
      key_binding_prefix = 'Lusty' + self.class.to_s.sub(/.*::/,'')

      @display.create(key_binding_prefix)
      set_syntax_matching()
    end

    def highlight_selected_index
      # Note: overridden by BufferGrep
      VIM::command 'syn clear LustySelected'

      entry = @current_sorted_matches[@selected_index]
      return if entry.nil?

      escaped = VIM::regex_escape(entry.label)
      label_match_string = Display.entry_syntaxify(escaped, false)
      VIM::command "syn match LustySelected \"#{label_match_string}\" " \
                                            'contains=LustyGrepMatch'
    end

    def choose(open_mode)
      entry = @current_sorted_matches[@selected_index]
      return if entry.nil?
      open_entry(entry, open_mode)
    end

    def cleanup
      @display.close
      Window.select @calling_window
      @settings.restore
      @running = false
      VIM::message ""
      LustyE::assert(@calling_window == $curwin)
    end

    # Pure virtual methods
    # - set_syntax_matching
    # - on_refresh
    # - open_entry
    # - compute_sorted_matches

end
end


module LustyE
class BufferExplorer < Explorer
  public
    def initialize
      super
      @prompt = Prompt.new
      @buffer_entries = []
    end

    def run
      unless @running
        @prompt.clear!
        @curbuf_at_start = VIM::Buffer.current
        @buffer_entries = BufferEntry::compute_buffer_entries()
        @buffer_entries.each do |e|
          # Show modification indicator
          e.label = e.short_name
          e.label << " [+]" if e.vim_buffer.modified?
          # Disabled: show buffer number next to name
          #e.label << " #{buffer.number.to_s}"
        end

        @selected_index = 0
        super
      end
    end

  private
    def title
      '[LustyExplorer-Buffers]'
    end

    def set_syntax_matching
      # Base highlighting -- more is set on refresh.
      if VIM::has_syntax?
        VIM::command 'syn match LustySlash "/" contained'
        VIM::command 'syn match LustyDir "\%(\S\+ \)*\S\+/" ' \
                                         'contains=LustySlash'
        VIM::command 'syn match LustyModified " \[+\]"'
      end
    end

    def curbuf_match_string
      curbuf = @buffer_entries.find { |x| x.vim_buffer == @curbuf_at_start }
      if curbuf
        escaped = VIM::regex_escape(curbuf.label)
        Display.entry_syntaxify(escaped, @prompt.insensitive?)
      else
        ""
      end
    end

    def on_refresh
      # Highlighting for the current buffer name.
      if VIM::has_syntax?
        VIM::command 'syn clear LustyCurrentBuffer'
        VIM::command 'syn match LustyCurrentBuffer ' \
                     "\"#{curbuf_match_string()}\" " \
                     'contains=LustyModified'
      end
    end

    def current_abbreviation
      @prompt.input
    end

    def compute_sorted_matches
      abbrev = current_abbreviation()

      if abbrev.length == 0
        # Take (current) MRU order if we have no abbreviation.
        @buffer_entries
      else
        matching_entries = \
          @buffer_entries.select { |x|
            x.current_score = Mercury.score(x.short_name, abbrev)
            x.current_score != 0.0
          }

        # Sort by score.
        matching_entries.sort! { |x, y|
          if x.current_score == y.current_score
            x.mru_placement <=> y.mru_placement
          else
            y.current_score <=> x.current_score
          end
        }
      end
    end

    def open_entry(entry, open_mode)
      cleanup()
      LustyE::assert($curwin == @calling_window)

      number = entry.vim_buffer.number
      LustyE::assert(number)

      cmd = case open_mode
            when :current_tab
              "b"
            when :new_tab
              # For some reason just using tabe or e gives an error when
              # the alternate-file isn't set.
              "tab split | b"
            when :new_split
	      "sp | b"
            when :new_vsplit
	      "vs | b"
            else
              LustyE::assert(false, "bad open mode")
            end

      VIM::command "silent #{cmd} #{number}"
    end
end
end


module LustyE
class FilesystemExplorer < Explorer
  public
    def initialize
      super
      @prompt = FilesystemPrompt.new
      @memoized_dir_contents = {}
    end

    def run
      return if @running

      FileMasks.create_glob_masks()
      @vim_swaps = VimSwaps.new
      @selected_index = 0
      super
    end

    def run_from_path(path)
      return if @running
      if path.empty?
        path = VIM::getcwd()
      end
      if path.respond_to?(:force_encoding)
        path = path.force_encoding(VIM::evaluate('&enc'))
      end
      @prompt.set!(path + File::SEPARATOR)
      run()
    end

    def key_pressed()
      i = VIM::evaluate("a:code_arg").to_i

      case i
      when 1, 10  # <C-a>, <Shift-Enter>
        cleanup()
        # Open all non-directories currently in view.
        @current_sorted_matches.each do |e|
          path_str = \
            if @prompt.at_dir?
              @prompt.input + e.label
            else
              dir = @prompt.dirname
              if dir == '/'
                dir + e.label
              else
                dir + File::SEPARATOR + e.label
              end
            end

          load_file(path_str, :current_tab) unless File.directory?(path_str)
        end
      when 5      # <C-e> edit file, create it if necessary
        if not @prompt.at_dir?
          cleanup()
          # Force a reread of this directory so that the new file will
          # show up (as long as it is saved before the next run).
          @memoized_dir_contents.delete(view_path())
          load_file(@prompt.input, :current_tab)
        end
      when 18     # <C-r> refresh
        @memoized_dir_contents.delete(view_path())
        refresh(:full)
      else
        super
      end
    end

  private
    def title
      '[LustyExplorer-Files]'
    end

    def set_syntax_matching
      # Base highlighting -- more is set on refresh.
      if VIM::has_syntax?
        VIM::command 'syn match LustySlash "/" contained'
        VIM::command 'syn match LustyDir "\%(\S\+ \)*\S\+/" ' \
                                         'contains=LustySlash'
      end
    end

    def on_refresh
      if VIM::has_syntax?
        VIM::command 'syn clear LustyFileWithSwap'

        view = view_path()
        @vim_swaps.file_names.each do |file_with_swap|
          if file_with_swap.dirname == view
            base = file_with_swap.basename
            escaped = VIM::regex_escape(base.to_s)
            match_str = Display.entry_syntaxify(escaped, false)
            VIM::command "syn match LustyFileWithSwap \"#{match_str}\""
          end
        end
      end

      # TODO: restore highlighting for open buffers?
    end

    def current_abbreviation
      if @prompt.at_dir?
        ""
      else
        File.basename(@prompt.input)
      end
    end

    def view_path
      input = @prompt.input

      path = \
        if @prompt.at_dir? and \
           input.length > 1         # Not root
          # The last element in the path is a directory + '/' and we want to
          # see what's in it instead of what's in its parent directory.

          Pathname.new(input[0..-2])  # Canonicalize by removing trailing '/'
        else
          Pathname.new(input).dirname
        end

      return path
    end

    def all_files_at_view
      view = view_path()

      unless @memoized_dir_contents.has_key?(view)

        if not view.directory?
          return []
        elsif not view.readable?
          # TODO: show "-- PERMISSION DENIED --"
          return []
        end

        # Generate an array of the files
        entries = []
        view_str = view.to_s
        unless LustyE::ends_with?(view_str, File::SEPARATOR)
          # Don't double-up on '/' -- makes Cygwin sad.
          view_str << File::SEPARATOR
        end

        Dir.foreach(view_str) do |name|
          next if name == "."   # Skip pwd
          next if name == ".." and LustyE::option_set?("AlwaysShowDotFiles")

          # Hide masked files.
          next if FileMasks.masked?(name)

          if FileTest.directory?(view_str + name)
            name << File::SEPARATOR
          end
          entries << FilesystemEntry.new(name)
        end
        @memoized_dir_contents[view] = entries
      end

      all = @memoized_dir_contents[view]

      if LustyE::option_set?("AlwaysShowDotFiles") or \
         current_abbreviation()[0] == ?.
        all
      else
        # Filter out dotfiles if the current abbreviation doesn't start with
        # '.'.
        all.select { |x| x.label[0] != ?. }
      end
    end

    def compute_sorted_matches
      abbrev = current_abbreviation()

      unsorted = all_files_at_view()

      if abbrev.length == 0
        # Sort alphabetically if we have no abbreviation.
        unsorted.sort { |x, y| x.label <=> y.label }
      else
        matches = \
          unsorted.select { |x|
            x.current_score = Mercury.score(x.label, abbrev)
            x.current_score != 0.0
          }

        if abbrev == '.'
          # Sort alphabetically, otherwise it just looks weird.
          matches.sort! { |x, y| x.label <=> y.label }
        else
          # Sort by score.
          matches.sort! { |x, y| y.current_score <=> x.current_score }
        end
      end
    end

    def open_entry(entry, open_mode)
      path = view_path() + entry.label

      if File.directory?(path)
        # Recurse into the directory instead of opening it.
        @prompt.set!(path.to_s)
        @selected_index = 0
      elsif entry.label.include?(File::SEPARATOR)
        # Don't open a fake file/buffer with "/" in its name.
        return
      else
        cleanup()
        load_file(path.to_s, open_mode)
      end
    end

    def load_file(path_str, open_mode)
      LustyE::assert($curwin == @calling_window)
      # Escape for Vim and remove leading ./ for files in pwd.
      filename_escaped = VIM::filename_escape(path_str).sub(/^\.\//,"")
      single_quote_escaped = VIM::single_quote_escape(filename_escaped)
      sanitized = VIM::evaluate "fnamemodify('#{single_quote_escaped}', ':.')"
      cmd = case open_mode
            when :current_tab
              "e"
            when :new_tab
              "tabe"
            when :new_split
	      "sp"
            when :new_vsplit
	      "vs"
            else
              LustyE::assert(false, "bad open mode")
            end

      VIM::command "silent #{cmd} #{sanitized}"
    end
end
end


# TODO:
# - some way for user to indicate case-sensitive regex
# - add slash highlighting back to file name?

module LustyE
class BufferGrep < Explorer
  public
    def initialize
      super
      @display.single_column_mode = true
      @prompt = Prompt.new
      @buffer_entries = []
      @matched_strings = []

      # State from previous run, so you don't have to retype
      # your search each time to get the previous entries.
      @previous_input = ''
      @previous_grep_entries = []
      @previous_matched_strings = []
      @previous_selected_index = 0
    end

    def run
      return if @running

      @prompt.set! @previous_input
      @buffer_entries = GrepEntry::compute_buffer_entries()

      @selected_index = @previous_selected_index
      super
    end

  private
    def title
      '[LustyExplorer-BufferGrep]'
    end

    def set_syntax_matching
      VIM::command 'syn clear LustyGrepFileName'
      VIM::command 'syn clear LustyGrepLineNumber'
      VIM::command 'syn clear LustyGrepContext'

      # Base syntax matching -- others are set on refresh.

      VIM::command \
        'syn match LustyGrepFileName "^\zs.\{-}\ze:\d\+:" ' \
                                     'contains=NONE ' \
                                     'nextgroup=LustyGrepLineNumber'

      VIM::command \
        'syn match LustyGrepLineNumber ":\d\+:" ' \
                                       'contained ' \
                                       'contains=NONE ' \
                                       'nextgroup=LustyGrepContext'

      VIM::command \
        'syn match LustyGrepContext ".*" ' \
                                    'transparent ' \
                                    'contained ' \
                                    'contains=LustyGrepMatch'
    end

    def on_refresh
      if VIM::has_syntax?

        VIM::command 'syn clear LustyGrepMatch'

        if not @matched_strings.empty?
          sub_regexes = @matched_strings.map { |s| VIM::regex_escape(s) }
          syntax_regex = '\%(' + sub_regexes.join('\|') + '\)'
          VIM::command "syn match LustyGrepMatch \"#{syntax_regex}\" " \
                                                    "contained " \
                                                    "contains=NONE"
        end
      end
    end

    def highlight_selected_index
      VIM::command 'syn clear LustySelected'

      entry = @current_sorted_matches[@selected_index]
      return if entry.nil?

      match_string = "#{entry.short_name}:#{entry.line_number}:"
      escaped = VIM::regex_escape(match_string)
      VIM::command "syn match LustySelected \"^#{match_string}\" " \
                                            'contains=NONE ' \
                                            'nextgroup=LustyGrepContext'
    end

    def current_abbreviation
      @prompt.input
    end

    def compute_sorted_matches
      abbrev = current_abbreviation()

      grep_entries = @previous_grep_entries
      @matched_strings = @previous_matched_strings

      @previous_input = ''
      @previous_grep_entries = []
      @previous_matched_strings = []
      @previous_selected_index = 0

      if not grep_entries.empty?
        return grep_entries
      elsif abbrev == ''
        @buffer_entries.each do |e|
          e.label = e.short_name
        end
        return @buffer_entries
      end

      begin
        regex = Regexp.compile(abbrev, Regexp::IGNORECASE)
      rescue RegexpError => e
        return []
      end

      max_visible_entries = Display.max_height

      # Used to avoid duplicating match strings, which slows down refresh.
      highlight_hash = {}

      # Search through every line of every open buffer for the
      # given expression.
      @buffer_entries.each do |entry|
        vim_buffer = entry.vim_buffer
        line_count = vim_buffer.count
        (1..line_count). each do |i|
          line = vim_buffer[i]
          match = regex.match(line)
          if match
            matched_str = match.to_s

            grep_entry = entry.clone()
            grep_entry.line_number = i
            grep_entry.label = "#{grep_entry.short_name}:#{i}:#{line}"
            grep_entries << grep_entry

            # Keep track of all matched strings
            unless highlight_hash[matched_str]
              @matched_strings << matched_str
              highlight_hash[matched_str] = true
            end

            if grep_entries.length > max_visible_entries
              return grep_entries
            end
          end
        end
      end

      return grep_entries
    end

    def open_entry(entry, open_mode)
      cleanup()
      LustyE::assert($curwin == @calling_window)

      number = entry.vim_buffer.number
      LustyE::assert(number)

      cmd = case open_mode
            when :current_tab
              "b"
            when :new_tab
              # For some reason just using tabe or e gives an error when
              # the alternate-file isn't set.
              "tab split | b"
            when :new_split
	      "sp | b"
            when :new_vsplit
	      "vs | b"
            else
              LustyE::assert(false, "bad open mode")
            end

      # Open buffer and go to the line number.
      VIM::command "silent #{cmd} #{number}"
      VIM::command "#{entry.line_number}"
    end

    def cleanup
      @previous_input = @prompt.input
      @previous_grep_entries = @current_sorted_matches
      @previous_matched_strings = @matched_strings
      @previous_selected_index = @selected_index
      super
    end
end
end


module LustyE

# Used in BufferExplorer
class Prompt
  private
    @@PROMPT = ">> "

  public
    def initialize
      clear!
    end

    def clear!
      @input = ""
    end

    def print(max_width = 0)
      text = @input
      # may need some extra characters for "..." and spacing
      max_width -= 5
      if max_width > 0 && text.length > max_width
        text = "..." + text[(text.length - max_width + 3 ) .. -1]
      end

      VIM::pretty_msg("Comment", @@PROMPT,
                      "None", VIM::single_quote_escape(text),
                      "Underlined", " ")
    end

    def set!(s)
      @input = s
    end

    def input
      @input
    end

    def insensitive?
      @input == @input.downcase
    end

    def ends_with?(c)
      LustyE::ends_with?(@input, c)
    end

    def add!(s)
      @input << s
    end

    def backspace!
      @input.chop!
    end

    def up_one_dir!
      @input.chop!
      while !@input.empty? and @input[-1] != ?/
        @input.chop!
      end
    end
end

# Used in FilesystemExplorer
class FilesystemPrompt < Prompt

  def initialize
    super
    @memoized = nil
    @dirty = true
  end

  def clear!
    super
    @dirty = true
  end

  def set!(s)
    # On Windows, Vim will return paths with a '\' separator, but
    # we want to use '/'.
    super(s.gsub('\\', '/'))
    @dirty = true
  end

  def backspace!
    super
    @dirty = true
  end

  def up_one_dir!
    super
    @dirty = true
  end

  def at_dir?
    # We have not typed anything yet or have just typed the final '/' on a
    # directory name in pwd.  This check is interspersed throughout
    # FilesystemExplorer because of the conventions of basename and dirname.
    input().empty? or input()[-1] == File::SEPARATOR[0]
    # Don't think the File.directory? call is necessary, but leaving this
    # here as a reminder.
    #(File.directory?(input()) and input().ends_with?(File::SEPARATOR))
  end

  def insensitive?
    at_dir? or (basename() == basename().downcase)
  end

  def add!(s)
    # Assumption: add!() will only receive enough chars at a time to complete
    # a single directory level, e.g. foo/, not foo/bar/

    @input << s
    @dirty = true
  end

  def input
    if @dirty
      @memoized = LustyE::simplify_path(variable_expansion(@input))
      @dirty = false
    end

    @memoized
  end

  def basename
    File.basename input()
  end

  def dirname
    File.dirname input()
  end

  private
    def variable_expansion (input_str)
      strings = input_str.split('$', -1)
      return "" if strings.nil? or strings.length == 0

      first = strings.shift

      # Try to expand each instance of $<word>.
      strings.inject(first) { |str, s|
        if s =~ /^(\w+)/ and ENV[$1]
          str + s.sub($1, ENV[$1])
        else
          str + "$" + s
        end
      }
    end
end

end


# Simplify switching between windows.
module LustyE
class Window
    def self.select(window)
      return true if window == $curwin

      start = $curwin

      # Try to select the given window.
      begin
        VIM::command "wincmd w"
      end while ($curwin != window) and ($curwin != start)

      if $curwin == window
        return true
      else
        # Failed -- re-select the starting window.
        VIM::command("wincmd w") while $curwin != start
        VIM::pretty_msg("ErrorMsg", "Cannot find the correct window!")
        return false
      end
    end
end
end


# Save and restore settings when creating the explorer buffer.
module LustyE
class SavedSettings
  def initialize
    save()
  end

  def save
    @timeoutlen = VIM::evaluate("&timeoutlen")

    @splitbelow = VIM::evaluate_bool("&splitbelow")
    @insertmode = VIM::evaluate_bool("&insertmode")
    @showcmd = VIM::evaluate_bool("&showcmd")
    @list = VIM::evaluate_bool("&list")

    @report = VIM::evaluate("&report")
    @sidescroll = VIM::evaluate("&sidescroll")
    @sidescrolloff = VIM::evaluate("&sidescrolloff")

    VIM::command "let s:win_size_restore = winrestcmd()"
  end

  def restore
    VIM::set_option "timeoutlen=#{@timeoutlen}"

    if @splitbelow
      VIM::set_option "splitbelow"
    else
      VIM::set_option "nosplitbelow"
    end

    if @insertmode
      VIM::set_option "insertmode"
    else
      VIM::set_option "noinsertmode"
    end

    if @showcmd
      VIM::set_option "showcmd"
    else
      VIM::set_option "noshowcmd"
    end

    if @list
      VIM::set_option "list"
    else
      VIM::set_option "nolist"
    end

    VIM::command "set report=#{@report}"
    VIM::command "set sidescroll=#{@sidescroll}"
    VIM::command "set sidescrolloff=#{@sidescrolloff}"

    VIM::command "exe s:win_size_restore"
  end
end
end


# Manage the explorer buffer.
module LustyE

class Display
  private
    @@COLUMN_SEPARATOR = "    "
    @@NO_MATCHES_STRING = "-- NO MATCHES --"
    @@TRUNCATED_STRING = "-- TRUNCATED --"

  public
    ENTRY_START_VIM_REGEX = '\%(^\|' + @@COLUMN_SEPARATOR + '\)'
    ENTRY_END_VIM_REGEX = '\%(\s*$\|' + @@COLUMN_SEPARATOR + '\)'

    def self.entry_syntaxify(s, case_insensitive)
      # Create a match regex string for the given s.  This is for a Vim regex,
      # not for a Ruby regex.

      str = "#{ENTRY_START_VIM_REGEX}\\zs#{s}\\ze#{ENTRY_END_VIM_REGEX}"

      str << '\c' if case_insensitive

      return str
    end

    attr_writer :single_column_mode
    def initialize(title)
      @title = title
      @window = nil
      @buffer = nil
      @single_column_mode = false
    end

    def create(prefix)

      # Make a window for the display and move there.
      # Start at size 1 to mitigate flashing effect when
      # we resize the window later.
      VIM::command "silent! botright 1split #{@title}"

      @window = $curwin
      @buffer = $curbuf

      #
      # Display buffer is special -- set options.
      #

      # Buffer-local.
      VIM::command "setlocal bufhidden=delete"
      VIM::command "setlocal buftype=nofile"
      VIM::command "setlocal nomodifiable"
      VIM::command "setlocal noswapfile"
      VIM::command "setlocal nowrap"
      VIM::command "setlocal nonumber"
      VIM::command "setlocal foldcolumn=0"
      VIM::command "setlocal nocursorline"
      VIM::command "setlocal nospell"
      VIM::command "setlocal nobuflisted"
      VIM::command "setlocal textwidth=0"
      VIM::command "setlocal noreadonly"

      # Non-buffer-local (Vim is annoying).
      # (Update SavedSettings if adding to below.)
      VIM::set_option "timeoutlen=0"
      VIM::set_option "noinsertmode"
      VIM::set_option "noshowcmd"
      VIM::set_option "nolist"
      VIM::set_option "report=9999"
      VIM::set_option "sidescroll=0"
      VIM::set_option "sidescrolloff=0"

      # TODO -- cpoptions?

      #
      # Syntax highlighting.
      #

      if VIM::has_syntax?
        # General syntax matching.
        VIM::command 'syn match LustyNoEntries "\%^\s*' \
                                               "#{@@NO_MATCHES_STRING}" \
                                               '\s*\%$"'
        VIM::command 'syn match LustyTruncated "^\s*' \
                                               "#{@@TRUNCATED_STRING}" \
                                               '\s*$"'

        # Colour highlighting.
        VIM::command 'highlight link LustyDir Directory'
        VIM::command 'highlight link LustySlash Function'
        VIM::command 'highlight link LustySelected Type'
        VIM::command 'highlight link LustyModified Special'
        VIM::command 'highlight link LustyCurrentBuffer Constant'
        VIM::command 'highlight link LustyGrepMatch IncSearch'
        VIM::command 'highlight link LustyGrepLineNumber Directory'
        VIM::command 'highlight link LustyGrepFileName Comment'
        VIM::command 'highlight link LustyGrepContext None' # transparent
        VIM::command 'highlight link LustyOpenedFile PreProc'
        VIM::command 'highlight link LustyFileWithSwap WarningMsg'
        VIM::command 'highlight link LustyNoEntries ErrorMsg'
        VIM::command 'highlight link LustyTruncated Visual'

        if VIM::exists? '*clearmatches'
          VIM::evaluate 'clearmatches()'
        end
      end

      #
      # Key mappings - we need to reroute user input.
      #

      # Non-special printable characters.
      printables =  '/!"#$%&\'()*+,-.0123456789:<=>?#@"' \
                    'ABCDEFGHIJKLMNOPQRSTUVWXYZ' \
                    '[]^_`abcdefghijklmnopqrstuvwxyz{}~'

      map = "noremap <silent> <buffer>"

      printables.each_byte do |b|
        VIM::command "#{map} <Char-#{b}> :call <SID>#{prefix}KeyPressed(#{b})<CR>"
      end

      # Special characters
      VIM::command "#{map} <Tab>    :call <SID>#{prefix}KeyPressed(9)<CR>"
      VIM::command "#{map} <Bslash> :call <SID>#{prefix}KeyPressed(92)<CR>"
      VIM::command "#{map} <Space>  :call <SID>#{prefix}KeyPressed(32)<CR>"
      VIM::command "#{map} \026|    :call <SID>#{prefix}KeyPressed(124)<CR>"

      VIM::command "#{map} <BS>     :call <SID>#{prefix}KeyPressed(8)<CR>"
      VIM::command "#{map} <Del>    :call <SID>#{prefix}KeyPressed(8)<CR>"
      VIM::command "#{map} <C-h>    :call <SID>#{prefix}KeyPressed(8)<CR>"

      VIM::command "#{map} <CR>     :call <SID>#{prefix}KeyPressed(13)<CR>"
      VIM::command "#{map} <S-CR>   :call <SID>#{prefix}KeyPressed(10)<CR>"
      VIM::command "#{map} <C-a>    :call <SID>#{prefix}KeyPressed(1)<CR>"

      VIM::command "#{map} <Esc>    :call <SID>#{prefix}Cancel()<CR>"
      VIM::command "#{map} <C-c>    :call <SID>#{prefix}Cancel()<CR>"
      VIM::command "#{map} <C-g>    :call <SID>#{prefix}Cancel()<CR>"

      VIM::command "#{map} <C-w>    :call <SID>#{prefix}KeyPressed(23)<CR>"
      VIM::command "#{map} <C-n>    :call <SID>#{prefix}KeyPressed(14)<CR>"
      VIM::command "#{map} <C-p>    :call <SID>#{prefix}KeyPressed(16)<CR>"
      VIM::command "#{map} <C-f>    :call <SID>#{prefix}KeyPressed(6)<CR>"
      VIM::command "#{map} <C-b>    :call <SID>#{prefix}KeyPressed(2)<CR>"
      VIM::command "#{map} <C-o>    :call <SID>#{prefix}KeyPressed(15)<CR>"
      VIM::command "#{map} <C-t>    :call <SID>#{prefix}KeyPressed(20)<CR>"
      VIM::command "#{map} <C-v>    :call <SID>#{prefix}KeyPressed(22)<CR>"
      VIM::command "#{map} <C-e>    :call <SID>#{prefix}KeyPressed(5)<CR>"
      VIM::command "#{map} <C-r>    :call <SID>#{prefix}KeyPressed(18)<CR>"
      VIM::command "#{map} <C-u>    :call <SID>#{prefix}KeyPressed(21)<CR>"
      VIM::command "#{map} <Esc>OD  :call <SID>#{prefix}KeyPressed(2)<CR>"
      VIM::command "#{map} <Esc>OC  :call <SID>#{prefix}KeyPressed(6)<CR>"
      VIM::command "#{map} <Esc>OA  :call <SID>#{prefix}KeyPressed(16)<CR>"
      VIM::command "#{map} <Esc>OB  :call <SID>#{prefix}KeyPressed(14)<CR>"
      VIM::command "#{map} <Left>   :call <SID>#{prefix}KeyPressed(2)<CR>"
      VIM::command "#{map} <Right>  :call <SID>#{prefix}KeyPressed(6)<CR>"
      VIM::command "#{map} <Up>     :call <SID>#{prefix}KeyPressed(16)<CR>"
      VIM::command "#{map} <Down>   :call <SID>#{prefix}KeyPressed(14)<CR>"
    end

    def print(strings)
      Window.select(@window) || return

      if strings.empty?
        print_no_entries()
        return
      end

      row_count, col_count, col_widths, truncated = \
        compute_optimal_layout(strings)

      # Slice the strings into rows.
      rows = Array.new(row_count){[]}
      col_index = 0
      strings.each_slice(row_count) do |column|
        column_width = col_widths[col_index]
        column.each_index do |i|
          string = column[i]

          rows[i] << string

          if col_index < col_count - 1
            # Add spacer to the width of the column
            rows[i] << (" " * (column_width - VIM::strwidth(string)))
            rows[i] << @@COLUMN_SEPARATOR
          end
        end

        col_index += 1
        break if col_index >= col_count
      end

      print_rows(rows, truncated)
      row_count
    end

    def close
      # Only wipe the buffer if we're *sure* it's the explorer.
      if Window.select @window and \
         $curbuf == @buffer and \
         $curbuf.name =~ /#{Regexp.escape(@title)}$/
          VIM::command "bwipeout!"
          @window = nil
          @buffer = nil
      end
    end

    def self.max_height
      stored_height = $curwin.height
      $curwin.height = VIM::MOST_POSITIVE_INTEGER
      highest_allowable = $curwin.height
      $curwin.height = stored_height
      highest_allowable
    end

    def self.max_width
      VIM::columns()
    end

  private

    def compute_optimal_layout(strings)
      # Compute optimal row count and corresponding column count.
      # The display attempts to fit `strings' on as few rows as
      # possible.

      max_width = Display.max_width()
      max_height = Display.max_height()
      displayable_string_upper_bound = compute_displayable_upper_bound(strings)

      # Determine optimal row count.
      optimal_row_count, truncated = \
        if @single_column_mode
          if strings.length <= max_height
            [strings.length, false]
          else
            [max_height - 1, true]
          end
        elsif strings.length > displayable_string_upper_bound
          # Use all available rows and truncate results.
          # The -1 is for the truncation indicator.
          [Display.max_height - 1, true]
        else
          single_row_width = \
            strings.inject(0) { |len, s|
              len + @@COLUMN_SEPARATOR.length + s.length
            }
          if single_row_width <= max_width or \
             strings.length == 1
            # All fits on a single row
            [1, false]
          else
            compute_optimal_row_count(strings)
          end
        end

      # Compute column_count and column_widths.
      column_count = 0
      column_widths = []
      total_width = 0
      strings.each_slice(optimal_row_count) do |column|
        longest = column.max { |a, b| VIM::strwidth(a) <=> VIM::strwidth(b) }
        column_width = VIM::strwidth(longest)
        total_width += column_width

        break if total_width > max_width

        column_count += 1
        column_widths << column_width
        total_width += @@COLUMN_SEPARATOR.length
      end

      [optimal_row_count, column_count, column_widths, truncated]
    end

    def print_rows(rows, truncated)
      unlock_and_clear()

      # Grow/shrink the window as needed
      $curwin.height = rows.length + (truncated ? 1 : 0)

      # Print the rows.
      rows.each_index do |i|
        $curwin.cursor = [i+1, 1]
        $curbuf.append(i, rows[i].join(''))
      end

      # Print a TRUNCATED indicator, if needed.
      if truncated
        $curbuf.append($curbuf.count - 1, \
                       @@TRUNCATED_STRING.center($curwin.width, " "))
      end

      # Stretch the last line to the length of the window with whitespace so
      # that we can "hide" the cursor in the corner.
      last_line = $curbuf[$curbuf.count - 1]
      last_line << (" " * [$curwin.width - last_line.length,0].max)
      $curbuf[$curbuf.count - 1] = last_line

      # There's a blank line at the end of the buffer because of how
      # VIM::Buffer.append works.
      $curbuf.delete $curbuf.count
      lock()
    end

    def print_no_entries
      unlock_and_clear()
      $curwin.height = 1
      $curbuf[1] = @@NO_MATCHES_STRING.center($curwin.width, " ")
      lock()
    end

    def unlock_and_clear
      VIM::command "setlocal modifiable"

      # Clear the explorer (black hole register)
      VIM::command "silent %d _"
    end

    def lock
      VIM::command "setlocal nomodifiable"

      # Hide the cursor
      VIM::command "normal! Gg$"
    end

    def compute_displayable_upper_bound(strings)
      # Compute an upper-bound on the number of displayable matches.
      # Basically: find the length of the longest string, then keep
      # adding shortest strings until we pass the width of the Vim
      # window.  This is the maximum possible column-count assuming
      # all strings can fit.  Then multiply by the number of rows.

      sorted_by_shortest = strings.sort { |x, y| x.length <=> y.length }
      longest_length = sorted_by_shortest.pop.length

      row_width = longest_length + @@COLUMN_SEPARATOR.length

      max_width = Display.max_width()
      column_count = 1

      sorted_by_shortest.each do |str|
        row_width += str.length
        if row_width > max_width
          break
        end

        column_count += 1
        row_width += @@COLUMN_SEPARATOR.length
      end

      column_count * Display.max_height()
    end

    def compute_optimal_row_count(strings)
      max_width = Display.max_width
      max_height = Display.max_height

      # Hashes by range, e.g. 0..2, representing the width
      # of the column bounded by that range.
      col_range_widths = {}

      # Binary search; find the lowest number of rows at which we
      # can fit all the strings.

      # We've already failed for a single row, so start at two.
      lower = 1  # (1 = 2 - 1)
      upper = max_height + 1
      while lower + 1 != upper
        row_count = (lower + upper) / 2   # Mid-point

        col_start_index = 0
        col_end_index = row_count - 1
        total_width = 0

        while col_end_index < strings.length
          total_width += \
            compute_column_width(col_start_index..col_end_index,
                                 strings, col_range_widths)

          if total_width > max_width
            # Early exit.
            total_width = LustyE::MOST_POSITIVE_FIXNUM
            break
          end

          total_width += @@COLUMN_SEPARATOR.length

          col_start_index += row_count
          col_end_index += row_count

          if col_end_index >= strings.length and \
             col_start_index < strings.length
            # Remainder; last iteration will not be a full column.
            col_end_index = strings.length - 1
          end
        end

        # The final column doesn't need a separator.
        total_width -= @@COLUMN_SEPARATOR.length

        if total_width <= max_width
          # This row count fits.
          upper = row_count
        else
          # This row count doesn't fit.
          lower = row_count
        end
      end

      if upper > max_height
        # No row count can accomodate all strings; have to truncate.
        # (-1 for the truncate indicator)
        [max_height - 1, true]
      else
        [upper, false]
      end
    end

    def compute_column_width(range, strings, col_range_widths)

      if (range.first == range.last)
        return strings[range.first].length
      end

      width = col_range_widths[range]

      if width.nil?
        # Recurse for each half of the range.
        split_point = range.first + ((range.last - range.first) >> 1)

        first_half = compute_column_width(range.first..split_point,
                                          strings, col_range_widths)
        second_half = compute_column_width(split_point+1..range.last,
                                           strings, col_range_widths)

        width = [first_half, second_half].max
        col_range_widths[range] = width
      end

      width
    end
end
end


module LustyE
class FileMasks
  private
    @@glob_masks = []

  public
    def FileMasks.create_glob_masks
      @@glob_masks = \
        if VIM::exists? "g:LustyExplorerFileMasks"
          # Note: this variable deprecated.
          VIM::evaluate("g:LustyExplorerFileMasks").split(',')
        elsif VIM::exists? "&wildignore"
          VIM::evaluate("&wildignore").split(',')
        else
          []
        end
    end

    def FileMasks.masked?(str)
      @@glob_masks.each do |mask|
        return true if File.fnmatch(mask, str)
      end

      return false
    end
end
end


module LustyE
class VimSwaps
  def initialize
    if VIM::has_syntax?
# FIXME: vvv disabled
#      @vim_r = IO.popen("vim -r --noplugin -i NONE 2>&1")
#      @files_with_swaps = nil
      @files_with_swaps = []
    else
      @files_with_swaps = []
    end
  end

  def file_names
    if @files_with_swaps.nil?
      if LustyE::ready_for_read?(@vim_r)
        @files_with_swaps = []
        @vim_r.each_line do |line|
          if line =~ /^ +file name: (.*)$/
            file = $1.chomp
            @files_with_swaps << Pathname.new(LustyE::simplify_path(file))
          end
        end
      else
        return []
      end
    end

    @files_with_swaps
  end
end
end


# Maintain MRU ordering.
module LustyE
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
          basename_to_prefix[k] = LustyE::longest_common_prefix(names)
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



$lusty_buffer_explorer = LustyE::BufferExplorer.new
$lusty_filesystem_explorer = LustyE::FilesystemExplorer.new
$lusty_buffer_grep = LustyE::BufferGrep.new
$le_buffer_stack = LustyE::BufferStack.new

EOF

" vim: set sts=2 sw=2:
