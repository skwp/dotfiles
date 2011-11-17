require 'rubygems'
require 'wirble'
# require 'hirb'
# Hirb::View.enable

# Wirble.init
# Wirble.colorize

IRB.conf[:AUTO_INDENT]=true
# require 'irb/completion'
require 'irb/ext/save-history'

IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history" 
IRB.conf[:PROMPT_MODE]  = :SIMPLE

