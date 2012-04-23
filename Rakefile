require 'rake'

desc "Hook our dotfiles into system-standard positions."
task :install => [:submodules] do
  puts
  puts "======================================================"
  puts "Welcome to YADR Installation. I'll ask you a few"
  puts "questions about which files to install. Nothing will"
  puts "be overwritten without your consent."
  puts "======================================================"
  puts
  # this has all the linkables from this directory.
  linkables = []
  linkables += Dir.glob('git/*') if want_to_install?('git')
  linkables += Dir.glob('irb/*') if want_to_install?('irb/pry')
  linkables += Dir.glob('ruby/*') if want_to_install?('ruby (gems)')
  linkables += Dir.glob('{vim,vimrc}') if want_to_install?('vim')
  linkables += Dir.glob('zsh/zshrc') if want_to_install?('zsh')
  Rake::Task['zsh_themes'].invoke

  skip_all = false
  overwrite_all = false
  backup_all = false

  linkables.each do |linkable|
    file = linkable.split('/').last
    source = "#{ENV["PWD"]}/#{linkable}"
    target = "#{ENV["HOME"]}/.#{file}"

    puts "--------"
    puts "file:   #{file}"
    puts "source: #{source}"
    puts "target: #{target}"

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
      run %{ mv "$HOME/.#{file}" "$HOME/.#{file}.backup" } if backup || backup_all
    end
    run %{ ln -s "#{source}" "#{target}" }
  end
  success_msg("installed")
end

task :zsh_themes do
  if File.exist?("#{ENV['HOME']}/.oh-my-zsh/modules/prompt/functions")
    puts "Detected oh-my-zsh @sorin-ionescu version."
    run %{ ln -nfs #{ENV["PWD"]}/oh-my-zsh/modules/prompt/functions/* $HOME/.oh-my-zsh/modules/prompt/functions/ } if want_to_install?('zsh themes')
  elsif File.exist?("#{ENV['HOME']}/.oh-my-zsh")
    puts "Detected oh-my-zsh @robbyrussell version."
    run %{ ln -nfs #{ENV["PWD"]}/oh-my-zsh/themes/* $HOME/.oh-my-zsh/themes/ } if want_to_install?('zsh themes')
  end
end

desc "Init and update submodules."
task :submodules do
  sh('git submodule update --init')
end

task :default => 'install'


private
def run(cmd)
  puts
  puts "[Installing] #{cmd}"
  `#{cmd}` unless ENV['DEBUG']
end

def want_to_install? (section)
  puts "Would you like to install configuration files for: #{section}? [y]es, [n]o"
  STDIN.gets.chomp == 'y'
end

def success_msg(action)
  puts ""
  puts "   _     _           _         "
  puts "  | |   | |         | |        "
  puts "  | |___| |_____  __| | ____   "
  puts "  |_____  (____ |/ _  |/ ___)  "
  puts "   _____| / ___ ( (_| | |      "
  puts "  (_______\_____|\____|_|      "
  puts ""
  puts "YADR has been #{action}. Please restart your terminal and vim."
end
