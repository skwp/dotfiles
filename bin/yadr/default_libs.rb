Dir[File.join(File.dirname(__FILE__),"lib/**/lib")].each {|dir| $LOAD_PATH << dir}
require 'git-style-binary/command'

$yadr = File.join(ENV['HOME'], ".yadr")
