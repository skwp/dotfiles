module GitStyleBinary
module Helpers
  module NameResolver

    def basename(filename=zero)
      File.basename(filename).match(/(.*?)(\-|$)/).captures.first
    end
    alias_method :primary_name, :basename

    # checks the bin directory for all files starting with +basename+ and
    # returns an array of strings specifying the subcommands
    def subcommand_names(filename=zero)
      subfiles = Dir[File.join(binary_directory, basename + "-*")]
      cmds = subfiles.collect{|file| File.basename(file).sub(/^#{basename}-/, '')}.sort
      cmds += built_in_command_names
      cmds.uniq
    end

    def binary_directory(filename=zero)
      File.dirname(filename)
    end

    def built_in_commands_directory
      File.dirname(__FILE__) + "/../commands"
    end

    def built_in_command_names
      Dir[built_in_commands_directory + "/*.rb"].collect{|f| File.basename(f.sub(/\.rb$/,''))}
    end

    def list_subcommands(filename=zero)
      subcommand_names(filename).join(", ")
    end

    # load first from users binary directory. then load built-in commands if
    # available
    def binary_filename_for(name)
      user_file = File.join(binary_directory, "#{basename}-#{name}") 
      return user_file if File.exists?(user_file)
      built_in = File.join(built_in_commands_directory, "#{name}.rb") 
      return built_in if File.exists?(built_in)
      user_file
    end

    def current_command_name(filename=zero,argv=ARGV)
      current = File.basename(zero)
      first_arg = ARGV[0]
      return first_arg if valid_subcommand?(first_arg)
      return basename if basename == current
      current.sub(/^#{basename}-/, '')
    end

    # returns the command name with the prefix if needed
    def full_current_command_name(filename=zero,argv=ARGV)
      cur = current_command_name(filename, argv)
      subcmd = cur == basename(filename) ? false : true # is this a subcmd?
      "%s%s%s" % [basename(filename), subcmd ? "-" : "", subcmd ? current_command_name(filename, argv) : ""]
    end

    def valid_subcommand?(name)
      subcommand_names.include?(name)
    end

    def zero
      $0
    end

    def pretty_known_subcommands(theme=:long)
      GitStyleBinary.known_commands.collect do |k,cmd| 
        next if k == basename 
        cmd.process_parser!
        ("%-s%s%-10s" % [basename, '-', k]).colorize(:light_blue) + ("%s       " % [theme == :long ? "\n" : ""]) + ("%s" % [cmd.short_desc]) + "\n"
      end.compact.sort
    end

  end
end
end
