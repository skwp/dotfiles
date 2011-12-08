module GitStyleBinary
class Parser < Trollop::Parser
  attr_reader :runs, :callbacks
  attr_reader :short_desc
  attr_accessor :command

  def initialize *a, &b
    super
    @runs = []
    setup_callbacks    
  end
  
  def setup_callbacks
    @callbacks =  {}
    %w(run).each do |event|
      %w(before after).each do |time|
        @callbacks["#{time}_#{event}".to_sym] = []
        instance_eval "def #{time}_#{event}(&block);@callbacks[:#{time}_#{event}] << block;end"
      end
    end
  end
  
  def run_callbacks(at, from)
    @callbacks[at].each {|c| c.call(from) }
  end

  def banner      s=nil; @banner     = s if s; @banner     end
  def short_desc  s=nil; @short_desc = s if s; @short_desc end
  def name_desc   s=nil; @name_desc = s if s; @name_desc end

  # Set the theme. Valid values are +:short+ or +:long+. Default +:long+
  attr_writer :theme

  def theme
    @theme ||= :long
  end
 
  ## Adds text to the help display.
  def text s; @order << [:text, s] end

  def spec_names
    @specs.collect{|name, spec| spec[:long]}
  end

  # should probably be somewhere else
  def load_all_commands
    GitStyleBinary.subcommand_names.each do |name|
      cmd_file = GitStyleBinary.binary_filename_for(name)
      GitStyleBinary.load_command_file(name, cmd_file)
    end
  end

  ## Print the help message to 'stream'.
  def educate(stream=$stdout)
    load_all_commands
    width # just calculate it now; otherwise we have to be careful not to
          # call this unless the cursor's at the beginning of a line.
    GitStyleBinary::Helpers::Pager.run_pager
    self.send("educate_#{theme}", stream) 
  end

  def educate_long(stream=$stdout)
    left = {}

    @specs.each do |name, spec| 
      left[name] = 
        ((spec[:short] ? "-#{spec[:short]}, " : "") +
        "--#{spec[:long]}" +
        case spec[:type]
        when :flag; ""
        when :int; "=<i>"
        when :ints; "=<i+>"
        when :string; "=<s>"
        when :strings; "=<s+>"
        when :float; "=<f>"
        when :floats; "=<f+>"
        end).colorize(:red)
    end

    leftcol_width = left.values.map { |s| s.length }.max || 0
    rightcol_start = leftcol_width + 6 # spaces
    leftcol_start = 6
    leftcol_spaces = " " * leftcol_start

    unless @order.size > 0 && @order.first.first == :text

      if @name_desc
        stream.puts "NAME".colorize(:red)
        stream.puts "#{leftcol_spaces}"+  colorize_known_words(eval(%Q["#{@name_desc}"])) + "\n"
        stream.puts
      end

      if @version
        stream.puts "VERSION".colorize(:red)
        stream.puts "#{leftcol_spaces}#@version\n"
      end
 
      stream.puts

      banner = colorize_known_words_array(wrap(eval(%Q["#{@banner}"]) + "\n", :prefix => leftcol_start)) if @banner # lazy banner
      stream.puts banner

      stream.puts
      stream.puts "OPTIONS".colorize(:red)
    else
      stream.puts "#@banner\n" if @banner
    end

    @order.each do |what, opt|
      if what == :text
        stream.puts wrap(opt)
        next
      end

      spec = @specs[opt]
      stream.printf "    %-#{leftcol_width}s\n", left[opt]
      desc = spec[:desc] + 
        if spec[:default]
          if spec[:desc] =~ /\.$/
            " (Default: #{spec[:default]})"
          else
            " (default: #{spec[:default]})"
          end
        else
          ""
        end
      stream.puts wrap("      %s" % [desc], :prefix => leftcol_start, :width => width - rightcol_start - 1 )
      stream.puts
      stream.puts
    end

  end

  def educate_short(stream=$stdout)
    left = {}

    @specs.each do |name, spec| 
      left[name] = "--#{spec[:long]}" +
        (spec[:short] ? ", -#{spec[:short]}" : "") +
        case spec[:type]
        when :flag; ""
        when :int; " <i>"
        when :ints; " <i+>"
        when :string; " <s>"
        when :strings; " <s+>"
        when :float; " <f>"
        when :floats; " <f+>"
        end
    end

    leftcol_width = left.values.map { |s| s.length }.max || 0
    rightcol_start = leftcol_width + 6 # spaces
    leftcol_start = 0

    unless @order.size > 0 && @order.first.first == :text
      stream.puts "#@version\n" if @version
      stream.puts colorize_known_words_array(wrap(eval(%Q["#{@banner}"]) + "\n", :prefix => leftcol_start)) if @banner # jit banner
      stream.puts "Options:"
    else
      stream.puts "#@banner\n" if @banner
    end

    @order.each do |what, opt|
      if what == :text
        stream.puts wrap(opt)
        next
      end

      spec = @specs[opt]
      stream.printf "  %#{leftcol_width}s:   ", left[opt]
      desc = spec[:desc] + 
        if spec[:default]
          if spec[:desc] =~ /\.$/
            " (Default: #{spec[:default]})"
          else
            " (default: #{spec[:default]})"
          end
        else
          ""
        end
      stream.puts wrap(desc, :width => width - rightcol_start - 1, :prefix => rightcol_start)
    end

  end


  def colorize_known_words_array(txts)
    txts.collect{|txt| colorize_known_words(txt)}
  end

  def colorize_known_words(txt)
    txt = txt.gsub(/^([A-Z]+\s*)$/, '\1'.colorize(:red))       # all caps words on their own line
    txt = txt.gsub(/\b(#{bin_name})\b/, '\1'.colorize(:light_blue))  # the current command name
    txt = txt.gsub(/\[([^\s]+)\]/, "[".colorize(:magenta) + '\1'.colorize(:green) + "]".colorize(:magenta)) # synopsis options
  end

  def consume(&block)
    cloaker(&block).bind(self).call
  end

  def consume_all(blocks)
    blocks.each {|b| consume(&b)}
  end

  def bin_name
    GitStyleBinary.full_current_command_name
  end

  def all_options_string
    # '#{spec_names.collect(&:to_s).collect{|name| "[".colorize(:magenta) + "--" + name + "]".colorize(:magenta)}.join(" ")} COMMAND [ARGS]'
    '#{spec_names.collect(&:to_s).collect{|name| "[" + "--" + name + "]"}.join(" ")} COMMAND [ARGS]'
  end

  def run(&block)
    @runs << block
  end
  
  def action(name = :action, &block)
    block.call(self) if block
  end
 
end
end
