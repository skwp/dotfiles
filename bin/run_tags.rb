#!/usr/bin/ruby
#-*-ruby-*-
# A script to run ctags on all .rb files in a project. Can be run on
# the current dir, called from a git callback, or install itself as a
# git post-merge and post-commit callback.
# More info here: http://vimeo.com/3989493
#
# This fork will work with homebrew installed ctags on OS X ("brew install ctags")
# Source: https://gist.github.com/1564787

CTAGS = '/usr/local/bin/ctags'
HOOKS = %w{ post-merge post-commit post-checkout }
HOOKS_DIR = '.git/hooks'

def install
  if !File.writable?(HOOKS_DIR)
    $stderr.print "The install option [-i] can only be used within a git repo; exiting.\n"
    exit 1
  end

  HOOKS.each { |hook| install_hook("#{HOOKS_DIR}/#{hook}") }
end

def run_tags(dir)
  if File.executable?(CTAGS) and File.writable?(dir)
    %x{find #{dir} -name \\*.rb | #{CTAGS} -f #{dir}/TAGS -L - 2>>/dev/null}
  else
    $stderr.print "FAILED to write TAGS file to #{dir}\n"
  end
end

def install_hook(hook)
  if File.exists?(hook)
    $stderr.print "A file already exists at #{hook}, and will NOT be replaced.\n"
    return
  end

  print "Linking #{__FILE__} to #{hook}\n"
  %x{ln -s #{__FILE__}  #{hook}}
end

if ARGV.first == '-i'
  install
else
  # if GIT_DIR is set, we are being called from git
  run_tags( ENV['GIT_DIR'] ? "#{ENV['GIT_DIR']}/.." : Dir.pwd )
end
