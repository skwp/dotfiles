#require 'fileutils'
#include FileUtils
require 'rake'
 
# The install task was stolen from RyanB
# http://github.com/ryanb/dotfiles

desc "install the snippets into user's vim directory @home"
task :install => ["snippets_dir:find"] do
  replace_all = false
  Dir['*'].each do |file|
    next if %w[Rakefile].include? file
    
    if File.exist?(File.join(@snippets_dir, "#{file}"))
      if replace_all
        replace_file(file)
      else
        print "overwrite #{File.join(@snippets_dir, file)}? [ynaq] "
        case $stdin.gets.chomp
        when 'a'
          replace_all = true
          replace_file(file)
        when 'y'
          replace_file(file)
        when 'q'
          exit
        else
          puts	File.join(@snippets_dir, "#{file}") 
        end
      end
    else
      link_file(file)
    end
  end
end
 
def replace_file(file)
  link_file(file)
end
 
def link_file(file)
  puts "linking #{path_to(file)}"
  ln_s File.join(FileUtils.pwd,file), path_to(file), :force => true
end

def path_to(file)
	File.join(@snippets_dir, "#{file}")
end


namespace :snippets_dir do
	desc "Sets @snippets_dir dependent on which OS You run" 
  task :find do
    @snippets_dir = File.join(ENV['VIMFILES'] || ENV['HOME'] || ENV['USERPROFILE'], RUBY_PLATFORM =~ /mswin32/ ? "vimfiles" : ".vim", "snippets")
  end

  desc "Purge the contents of the vim snippets directory"
  task :purge => ["snippets_dir:find"] do
    rm_rf @snippets_dir, :verbose => true if File.directory? @snippets_dir
    mkdir @snippets_dir, :verbose => true
  end
end

desc "Copy the snippets directories into ~/.vim/snippets"
task :deploy_local => ["snippets_dir:purge"] do
  Dir.foreach(".") do |f|
    cp_r f, @snippets_dir, :verbose => true if File.directory?(f) && f =~ /^[^\.]/
  end
  cp "support_functions.vim", @snippets_dir, :verbose => true
end

desc "Alias for purge"
task :purge => ["snippets_dir:purge"]

desc "Alias for default task run easy 'rake'"
task :default => :install
