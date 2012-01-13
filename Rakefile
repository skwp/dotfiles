require 'rake'

desc "Hook our dotfiles into system-standard positions."
task :install => :submodules do
  # this has all the linkables from this directory.
  linkables = []
  linkables += Dir.glob('git/*') if want_to_install?('git')
  linkables += Dir.glob('irb/*') if want_to_install?('irb/pry')
  linkables += Dir.glob('{vim,vimrc}') if want_to_install?('vim')
  linkables += Dir.glob('zsh/zshrc') if want_to_install?('zsh')

  # this grabs all of them from the user's custom directory.
  custom = Dir.glob("#{ENV["HOME"]}/.dotfiles/*").collect { |i| i.split('/').last }

  skip_all = false
  overwrite_all = false
  backup_all = false

  linkables.each do |linkable|
    overwrite = false
    backup = false

    file = linkable.split('/').last
    if (custom.include?(file))
      source = "#{ENV["HOME"]}/.dotfiles/#{file}"
    else
      source = "#{ENV["PWD"]}/#{linkable}"
    end
    target = "#{ENV["HOME"]}/.#{file}"


    if File.exists?(target) || File.symlink?(target)
      unless skip_all || overwrite_all || backup_all
        puts "File already exists: #{target}, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all"
        case STDIN.gets.chomp
        when 'o' then overwrite = true
        when 'b' then backup = true
        when 'O' then overwrite_all = true
        when 'B' then backup_all = true
        when 'S' then skip_all = true
        end
      end
      FileUtils.rm_rf(target) if overwrite || overwrite_all
      `mv "$HOME/.#{file}" "$HOME/.#{file}.backup"` if backup || backup_all
    end
    puts "--------"
    puts "file:   #{file}"
    puts "source: #{source}"
    puts "target: #{target}"
    `ln -s "#{source}" "#{target}"`
  end
end

task :commandt do
  Dir.chdir "vim/bundle/skwp-Command-T/ruby/command-t" do
    sh "ruby extconf.rb"
    sh "make clean && make"
  end
end

desc "Init and update submodules."
task :submodules do
  # sh("git submodule init")
  # sh("git submodule update")
end

task :default => 'install'

private

def want_to_install? (section)
  puts "Would you like to install configuration files for: #{section}? [y]es, [n]o"
  STDIN.gets.chomp == 'y'
end
