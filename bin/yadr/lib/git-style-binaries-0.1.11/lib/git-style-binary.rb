$:.unshift(File.dirname(__FILE__))
require 'rubygems'

# Load the vendor gems
$:.unshift(File.dirname(__FILE__) + "/../vendor/gems")
%w(trollop).each do |library|
  begin
    require "#{library}/lib/#{library}"
  rescue LoadError
    begin
      require 'trollop'
    rescue LoadError
      puts "There was an error loading #{library}. Try running 'gem install #{library}' to correct the problem" 
    end
  end
end

require 'ext/core'
require 'ext/colorize'
require 'git-style-binary/autorunner'
Dir[File.dirname(__FILE__) + "/git-style-binary/helpers/*.rb"].each {|f|  require f}

module GitStyleBinary
 
  class << self
    include Helpers::NameResolver
    attr_accessor :current_command
    attr_accessor :primary_command
    attr_writer :known_commands

    # If set to false GitStyleBinary will not automatically run at exit.
    attr_writer :run

    # Automatically run at exit?
    def run?
      @run ||= false
    end

    def parser
      @p ||= Parser.new
    end

    def known_commands
      @known_commands ||= {}
    end

    def load_primary
      unless @loaded_primary
        @loaded_primary = true
        primary_file = File.join(binary_directory, basename) 
        load primary_file

        if !GitStyleBinary.primary_command # you still dont have a primary load a default
          GitStyleBinary.primary do
            run do |command|
              educate
            end
          end
        end
      end
    end

    def load_subcommand
      unless @loaded_subcommand
        @loaded_subcommand = true
        cmd_file = GitStyleBinary.binary_filename_for(GitStyleBinary.current_command_name)
        load cmd_file
      end
    end

    def load_command_file(name, file)
      self.name_of_command_being_loaded = name
      load file
      self.name_of_command_being_loaded = nil
    end

    # UGLY eek
    attr_accessor :name_of_command_being_loaded
   
  end
end

at_exit do
  unless $! || GitStyleBinary.run?
    command = GitStyleBinary::AutoRunner.run
    exit 0
  end
end
