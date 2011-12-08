require 'git-style-binary/parser'

module GitStyleBinary
class AutoRunner

  def self.run(argv=ARGV)
    r = new
    r.run
  end

  def run
    unless GitStyleBinary.run?
      if !GitStyleBinary.current_command 
        GitStyleBinary.load_primary
      end
      GitStyleBinary.current_command.run
    end
  end

end
end
