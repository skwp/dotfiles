# == JazzFingers ===
# jazz_fingers gem: great syntax colorized printing
begin
  require 'jazz_fingers'
  # The following line enables awesome_print for all pry output,
  # and it also enables paging

  JazzFingers.configure do |config|
    config.colored_prompt = true
    config.amazing_print = true
    config.coolline = false
    config.application_name = MyAwesomeProject
  end
rescue LoadError => error
  puts "gem install jazz_fingers  # <-- highly recommended"
end
