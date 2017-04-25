require 'fileutils'

# => [String, String, ..]
files = Dir.entries("/Users/wesson.yi/")

files = files.map do |filename|
  File.expand_path(filename, "~")
end

files.each do |file|
  if File.ftype(file) == "link"
    FileUtils.remove file
    puts "Removed: #{file}"
  end
end

FileUtils.rm_rf(File.expand_path(".yadr", "~"))
puts "Removing the dotfile .yadr..."
puts "Removed: .yadr."


