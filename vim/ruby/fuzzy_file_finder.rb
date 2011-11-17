#--
# ==================================================================
# Author: Jamis Buck (jamis@jamisbuck.org)
# Date: 2008-10-09
# 
# This file is in the public domain. Usage, modification, and
# redistribution of this file are unrestricted.
# ==================================================================
#++

# The "fuzzy" file finder provides a way for searching a directory
# tree with only a partial name. This is similar to the "cmd-T"
# feature in TextMate (http://macromates.com).
# 
# Usage:
# 
#   finder = FuzzyFileFinder.new
#   finder.search("app/blogcon") do |match|
#     puts match[:highlighted_path]
#   end
#
# In the above example, all files matching "app/blogcon" will be
# yielded to the block. The given pattern is reduced to a regular
# expression internally, so that any file that contains those
# characters in that order (even if there are other characters
# in between) will match.
# 
# In other words, "app/blogcon" would match any of the following
# (parenthesized strings indicate how the match was made):
# 
# * (app)/controllers/(blog)_(con)troller.rb
# * lib/c(ap)_(p)ool/(bl)ue_(o)r_(g)reen_(co)loratio(n)
# * test/(app)/(blog)_(con)troller_test.rb
#
# And so forth.
class FuzzyFileFinder
  module Version
    MAJOR = 1
    MINOR = 0
    TINY  = 4
    STRING = [MAJOR, MINOR, TINY].join(".")
  end

  # This is the exception that is raised if you try to scan a
  # directory tree with too many entries. By default, a ceiling of
  # 10,000 entries is enforced, but you can change that number via
  # the +ceiling+ parameter to FuzzyFileFinder.new.
  class TooManyEntries < RuntimeError; end

  # Used internally to represent a run of characters within a
  # match. This is used to build the highlighted version of
  # a file name.
  class CharacterRun < Struct.new(:string, :inside) #:nodoc:
    def to_s
      if inside
        "(#{string})"
      else
        string
      end
    end
  end

  # Used internally to represent a file within the directory tree.
  class FileSystemEntry #:nodoc:
    attr_reader :parent
    attr_reader :name

    def initialize(parent, name)
      @parent = parent
      @name = name
    end

    def path
      File.join(parent.name, name)
    end
  end

  # Used internally to represent a subdirectory within the directory
  # tree.
  class Directory #:nodoc:
    attr_reader :name

    def initialize(name, is_root=false)
      @name = name
      @is_root = is_root
    end

    def root?
      is_root
    end
  end

  # The roots directory trees to search.
  attr_reader :roots

  # The list of files beneath all +roots+
  attr_reader :files

  # The maximum number of files beneath all +roots+
  attr_reader :ceiling

  # The prefix shared by all +roots+.
  attr_reader :shared_prefix

  # The list of glob patterns to ignore.
  attr_reader :ignores

  # Initializes a new FuzzyFileFinder. This will scan the
  # given +directories+, using +ceiling+ as the maximum number
  # of entries to scan. If there are more than +ceiling+ entries
  # a TooManyEntries exception will be raised.
  def initialize(directories=['.'], ceiling=10_000, ignores=nil)
    directories = Array(directories)
    directories << "." if directories.empty?

    # expand any paths with ~
    root_dirnames = directories.map { |d| File.expand_path(d) }.select { |d| File.directory?(d) }.uniq

    @roots = root_dirnames.map { |d| Directory.new(d, true) }
    @shared_prefix = determine_shared_prefix
    @shared_prefix_re = Regexp.new("^#{Regexp.escape(shared_prefix)}" + (shared_prefix.empty? ? "" : "/"))

    @files = []
    @ceiling = ceiling

    @ignores = Array(ignores)

    rescan!
  end

  # Rescans the subtree. If the directory contents every change,
  # you'll need to call this to force the finder to be aware of
  # the changes.
  def rescan!
    @files.clear
    roots.each { |root| follow_tree(root) }
  end

  # Takes the given +pattern+ (which must be a string) and searches
  # all files beneath +root+, yielding each match.
  #
  # +pattern+ is interpreted thus:
  #
  # * "foo" : look for any file with the characters 'f', 'o', and 'o'
  #   in its basename (discounting directory names). The characters
  #   must be in that order.
  # * "foo/bar" : look for any file with the characters 'b', 'a',
  #   and 'r' in its basename (discounting directory names). Also,
  #   any successful match must also have at least one directory
  #   element matching the characters 'f', 'o', and 'o' (in that
  #   order.
  # * "foo/bar/baz" : same as "foo/bar", but matching two
  #   directory elements in addition to a file name of "baz".
  #
  # Each yielded match will be a hash containing the following keys:
  #
  # * :path refers to the full path to the file
  # * :directory refers to the directory of the file
  # * :name refers to the name of the file (without directory)
  # * :highlighted_directory refers to the directory of the file with
  #   matches highlighted in parentheses.
  # * :highlighted_name refers to the name of the file with matches
  #   highlighted in parentheses
  # * :highlighted_path refers to the full path of the file with
  #   matches highlighted in parentheses
  # * :abbr refers to an abbreviated form of :highlighted_path, where
  #   path segments without matches are compressed to just their first
  #   character.
  # * :score refers to a value between 0 and 1 indicating how closely
  #   the file matches the given pattern. A score of 1 means the
  #   pattern matches the file exactly.
  def search(pattern, &block)
    pattern.gsub!(" ", "")
    path_parts = pattern.split("/")
    path_parts.push "" if pattern[-1,1] == "/"

    file_name_part = path_parts.pop || ""

    if path_parts.any?
      path_regex_raw = "^(.*?)" + path_parts.map { |part| make_pattern(part) }.join("(.*?/.*?)") + "(.*?)$"
      path_regex = Regexp.new(path_regex_raw, Regexp::IGNORECASE)
    end

    file_regex_raw = "^(.*?)" << make_pattern(file_name_part) << "(.*)$"
    file_regex = Regexp.new(file_regex_raw, Regexp::IGNORECASE)

    path_matches = {}
    files.each do |file|
      path_match = match_path(file.parent, path_matches, path_regex, path_parts.length)
      next if path_match[:missed]

      match_file(file, file_regex, path_match, &block)
    end
  end

  # Takes the given +pattern+ (which must be a string, formatted as
  # described in #search), and returns up to +max+ matches in an
  # Array. If +max+ is nil, all matches will be returned.
  def find(pattern, max=nil)
    results = []
    search(pattern) do |match|
      results << match
      break if max && results.length >= max
    end
    return results
  end

  # Displays the finder object in a sane, non-explosive manner.
  def inspect #:nodoc:
    "#<%s:0x%x roots=%s, files=%d>" % [self.class.name, object_id, roots.map { |r| r.name.inspect }.join(", "), files.length]
  end

  private

    # Recursively scans +directory+ and all files and subdirectories
    # beneath it, depth-first.
    def follow_tree(directory)
      Dir.entries(directory.name).each do |entry|
        next if entry[0,1] == "."
        next if ignore?(directory.name) # Ignore whole directory hierarchies
        raise TooManyEntries if files.length > ceiling

        full = File.join(directory.name, entry)

        if File.directory?(full)
          follow_tree(Directory.new(full))
        elsif !ignore?(full.sub(@shared_prefix_re, ""))
          files.push(FileSystemEntry.new(directory, entry))
        end
      end
    end

    # Returns +true+ if the given name matches any of the ignore
    # patterns.
    def ignore?(name)
      ignores.any? { |pattern| File.fnmatch(pattern, name) }
    end

    # Takes the given pattern string "foo" and converts it to a new
    # string "(f)([^/]*?)(o)([^/]*?)(o)" that can be used to create
    # a regular expression.
    def make_pattern(pattern)
      pattern = pattern.split(//)
      pattern << "" if pattern.empty?

      pattern.inject("") do |regex, character|
        regex << "([^/]*?)" if regex.length > 0
        regex << "(" << Regexp.escape(character) << ")"
      end
    end

    # Given a MatchData object +match+ and a number of "inside"
    # segments to support, compute both the match score and  the
    # highlighted match string. The "inside segments" refers to how
    # many patterns were matched in this one match. For a file name,
    # this will always be one. For directories, it will be one for
    # each directory segment in the original pattern.
    def build_match_result(match, inside_segments)
      runs = []
      inside_chars = total_chars = 0
      match.captures.each_with_index do |capture, index|
        if capture.length > 0
          # odd-numbered captures are matches inside the pattern.
          # even-numbered captures are matches between the pattern's elements.
          inside = index % 2 != 0

          total_chars += capture.gsub(%r(/), "").length # ignore '/' delimiters
          inside_chars += capture.length if inside

          if runs.last && runs.last.inside == inside
            runs.last.string << capture
          else
            runs << CharacterRun.new(capture, inside)
          end
        end
      end

      # Determine the score of this match.
      # 1. fewer "inside runs" (runs corresponding to the original pattern)
      #    is better.
      # 2. better coverage of the actual path name is better

      inside_runs = runs.select { |r| r.inside }
      run_ratio = inside_runs.length.zero? ? 1 : inside_segments / inside_runs.length.to_f

      char_ratio = total_chars.zero? ? 1 : inside_chars.to_f / total_chars

      score = run_ratio * char_ratio

      return { :score => score, :result => runs.join }
    end

    # Match the given path against the regex, caching the result in +path_matches+.
    # If +path+ is already cached in the path_matches cache, just return the cached
    # value.
    def match_path(path, path_matches, path_regex, path_segments)
      return path_matches[path] if path_matches.key?(path)

      name_with_slash = path.name + "/" # add a trailing slash for matching the prefix
      matchable_name = name_with_slash.sub(@shared_prefix_re, "")
      matchable_name.chop! # kill the trailing slash

      if path_regex
        match = matchable_name.match(path_regex)

        path_matches[path] =
          match && build_match_result(match, path_segments) ||
          { :score => 1, :result => matchable_name, :missed => true }
      else
        path_matches[path] = { :score => 1, :result => matchable_name }
      end
    end

    # Match +file+ against +file_regex+. If it matches, yield the match
    # metadata to the block.
    def match_file(file, file_regex, path_match, &block)
      if file_match = file.name.match(file_regex)
        match_result = build_match_result(file_match, 1)
        full_match_result = path_match[:result].empty? ? match_result[:result] : File.join(path_match[:result], match_result[:result])
        shortened_path = path_match[:result].gsub(/[^\/]+/) { |m| m.index("(") ? m : m[0,1] }
        abbr = shortened_path.empty? ? match_result[:result] : File.join(shortened_path, match_result[:result])

        result = { :path => file.path,
                   :abbr => abbr,
                   :directory => file.parent.name,
                   :name => file.name,
                   :highlighted_directory => path_match[:result],
                   :highlighted_name => match_result[:result],
                   :highlighted_path => full_match_result,
                   :score => path_match[:score] * match_result[:score] }
        yield result
      end
    end

    def determine_shared_prefix
      # the common case: if there is only a single root, then the entire
      # name of the root is the shared prefix.
      return roots.first.name if roots.length == 1

      split_roots = roots.map { |root| root.name.split(%r{/}) }
      segments = split_roots.map { |root| root.length }.max
      master = split_roots.pop

      segments.times do |segment|
        if !split_roots.all? { |root| root[segment] == master[segment] }
          return master[0,segment].join("/")
        end
      end

      # shouldn't ever get here, since we uniq the root list before
      # calling this method, but if we do, somehow...
      return roots.first.name
    end
end
