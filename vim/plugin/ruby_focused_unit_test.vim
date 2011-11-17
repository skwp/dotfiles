if !has("ruby")
  finish
end

command RunRubyFocusedUnitTest :call <SID>RunRubyFocusedUnitTest()
command RunRubyFocusedContext :call <SID>RunRubyFocusedContext()
command RunAllRubyTests :call <SID>RunAllRubyTests()
command RunLastRubyTest :call <SID>RunLastRubyTest()

function! s:RunRubyFocusedUnitTest()
  ruby RubyFocusedUnitTest.new.run_test
endfunction

function! s:RunRubyFocusedContext()
  ruby RubyFocusedUnitTest.new.run_context
endfunction

function! s:RunAllRubyTests()
  ruby RubyFocusedUnitTest.new.run_all
endfunction

function! s:RunLastRubyTest()
  ruby RubyFocusedUnitTest.new.run_last
endfunction

ruby << EOF
module VIM
  class Buffer
    class << self
      include Enumerable

      def each(&block)
        (0...VIM::Buffer.count).each do |index|
          yield self[index]
        end
      end

      def create(name, opts={})
        location = opts[:location] || :below
        VIM.command("#{location} new #{name}")
        buf = VIM::Buffer.current
        if opts[:text]
          buf.text = opts[:text]
        end
        buf
      end
    end

    def text=(content)
      content.split("\n").each_with_index do |line,index|
        self.append index, line
      end
    end

    def method_missing(method, *args, &block)
      VIM.command "#{method} #{self.name}"
    end
  end
end

class RubyFocusedUnitTest
  DEFAULT_OUTPUT_BUFFER = "rb_test_output"
  SAVED_TEST_COMMAND_FILE = '/tmp/last_ruby_focused_unit_test'

  def write_output_to_buffer(test_command)
    save_test_command(test_command)

    if buffer = VIM::Buffer.find { |b| b.name =~ /#{DEFAULT_OUTPUT_BUFFER}/ }
      buffer.bdelete!
    end

    buffer = VIM::Buffer.create DEFAULT_OUTPUT_BUFFER, :location => :below, :text => "--- Run Focused Unit Test ---\n\n"
    VIM.command("setlocal buftype=nowrite")
    VIM.command "redraw"

    IO.popen("#{test_command} 2>&1", "r") do |io|
      begin
        loop do
          input = io.readpartial(10)
          first, *rest = input.split(/\n/, -1)
          buffer[buffer.length] = buffer[buffer.length] + first
          rest.each {|l| buffer.append buffer.length, l }
          VIM.command "redraw"
        end
      rescue EOFError
      end
    end
  end

  def save_test_command(test_command)
    File.open(SAVED_TEST_COMMAND_FILE, 'w') { |f| f.write(test_command) }
  end

  def current_file
    VIM::Buffer.current.name
  end

  def spec_file?
    current_file =~ /spec_|_spec/
  end

  def line_number
    VIM::Buffer.current.line_number
  end

  def run_spec
    write_output_to_buffer("#{spec_command} '#{current_file}' -l #{line_number}")
  end

  def run_unit_test
    method_name = nil

    (line_number + 1).downto(1) do |line_number|
      if VIM::Buffer.current[line_number] =~ /def (test_\w+)/
        method_name = $1
        break
      elsif VIM::Buffer.current[line_number] =~ /test "([^"]+)"/ ||
            VIM::Buffer.current[line_number] =~ /test '([^']+)'/
        method_name = "test_" + $1.split(" ").join("_")
        break
      elsif VIM::Buffer.current[line_number] =~ /should "([^"]+)"/ ||
            VIM::Buffer.current[line_number] =~ /should '([^']+)'/
        method_name = "\"/#{Regexp.escape($1)}/\""
        break
      end
    end

    write_output_to_buffer("ruby #{current_file} -n #{method_name}") if method_name
  end

  def run_test
    if spec_file?
      run_spec
    else
      run_unit_test
    end
  end

  def run_context
    method_name = nil
    context_line_number = nil

    (line_number + 1).downto(1) do |line_number|
      if VIM::Buffer.current[line_number] =~ /(context|describe) "([^"]+)"/ ||
         VIM::Buffer.current[line_number] =~ /(context|describe) '([^']+)'/
        method_name = $2
        context_line_number = line_number
        break
      end
    end

    if method_name
      if spec_file?
        write_output_to_buffer("#{spec_command} #{current_file} -l #{context_line_number}")
      else
        method_name = "\"/#{Regexp.escape(method_name)}/\""
        write_output_to_buffer("ruby #{current_file} -n #{method_name}")
      end
    end
  end

  def run_all
    if spec_file?
      write_output_to_buffer("#{spec_command} '#{current_file}'")
    else
      write_output_to_buffer("ruby '#{current_file}'")
    end
  end

  def run_last
    write_output_to_buffer(File.read(SAVED_TEST_COMMAND_FILE))
  end

  def spec_command
    if File.exists?("Gemfile") && match = `bundle show rspec`.match(/(\d\.\d\.\d)$/)
      match.to_a.last.to_f < 2 ? "bundle exec spec" : "bundle exec rspec"
    else
      system("rspec -v > /dev/null 2>&1") ? "rspec --no-color" : "spec"
    end
  end
end
EOF
