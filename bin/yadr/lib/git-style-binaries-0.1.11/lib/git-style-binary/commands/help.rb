module GitStyleBinary
  module Commands
    class Help
      # not loving this syntax, but works for now
      GitStyleBinary.command do
        short_desc "get help for a specific command"
        run do |command|

          # this is slightly ugly b/c it has to muck around in the internals to
          # get information about commands other than itself. This isn't a
          # typical case
          self.class.send :define_method, :educate_about_command do |name|
            load_all_commands
            if GitStyleBinary.known_commands.has_key?(name)
              cmd = GitStyleBinary.known_commands[name]
              cmd.process_parser!
              cmd.parser.educate
            else
              puts "Unknown command '#{name}'"
            end
          end

          if command.argv.size > 0
            command.argv.first == "help" ? educate : educate_about_command(command.argv.first)
          else
            educate
          end
        end
      end
    end
  end
end
