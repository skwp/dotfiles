require 'rake'

desc "Hook our dotfiles into system-standard positions."
task :install => [:submodule_init, :submodules] do
  puts
  puts "======================================================"
  puts "Welcome to YADR Installation. I'll ask you a few"
  puts "questions about which files to install. Nothing will"
  puts "be overwritten without your consent."
  puts "======================================================"
  puts

  install_homebrew if RUBY_PLATFORM.downcase.include?("darwin")
  install_rvm_binstubs

  # this has all the runcoms from this directory.
  file_operation(Dir.glob('git/*')) if want_to_install?('git configs (color, aliases)')
  file_operation(Dir.glob('irb/*')) if want_to_install?('irb/pry configs (more colorful)')
  file_operation(Dir.glob('ruby/*')) if want_to_install?('rubygems config (faster/no docs)')
  file_operation(Dir.glob('ctags/*')) if want_to_install?('ctags config (better js/ruby support)')
  file_operation(Dir.glob('vimify/*')) if want_to_install?('vimification of command line tools')
  file_operation(Dir.glob('{vim,vimrc}')) if want_to_install?('vim configuration (highly recommended)')

  if want_to_install?('zsh enhancements & prezto')
    install_prezto
  end

  install_fonts if RUBY_PLATFORM.downcase.include?("darwin")

  success_msg("installed")
end

task :update => [:install] do
  #TODO: for now, we do the same as install. But it would be nice
  #not to clobber zsh files
end

task :submodule_init do
  run %{ git submodule update --init --recursive }
end

desc "Init and update submodules."
task :submodules do
  puts "======================================================"
  puts "Downloading YADR submodules...please wait"
  puts "======================================================"

  run %{
    cd $HOME/.yadr
    git submodule foreach 'git fetch origin; git checkout master; git reset --hard origin/master; git submodule update --recursive; git clean -dfx'
    git clean -dfx
  }
  puts
end

task :default => 'install'


private
def run(cmd)
  puts
  puts "[Running] #{cmd}"
  `#{cmd}` unless ENV['DEBUG']
end

def install_rvm_binstubs
  puts "======================================================"
  puts "Installing RVM Bundler support. Never have to type"
  puts "bundle exec again! Please use bundle --binstubs and RVM"
  puts "will automatically use those bins after cd'ing into dir."
  puts "======================================================"
  run %{ chmod +x $rvm_path/hooks/after_cd_bundler }
  puts
end

def install_homebrew
  puts "======================================================"
  puts "Installing Homebrew, the OSX package manager...If it's"
  puts "already installed, this will do nothing."
  puts "======================================================"
  run %{ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"}
  puts
  puts
  puts "======================================================"
  puts "Installing Homebrew packages...There may be some warnings."
  puts "======================================================"
  run %{brew install ack ctags git hub}
  puts
  puts
end

def install_fonts
  puts "======================================================"
  puts "Installing patched fonts for Powerline."
  puts "======================================================"
  run %{ cp -f $HOME/.yadr/fonts/* $HOME/Library/Fonts }
  puts
end

def install_prezto
  puts "Installing Prezto (ZSH Enhancements)..."

  unless File.exists?(File.join(ENV['ZDOTDIR'] || ENV['HOME'], ".zprezto"))
    run %{ ln -nfs "$HOME/.yadr/zsh/prezto" "${ZDOTDIR:-$HOME}/.zprezto" }
  end

  file_operation(Dir.glob('zsh/prezto/runcoms/z*'), :copy)

  puts "Creating directories for your customizations"
  run %{ mkdir -p $HOME/.zsh.before }
  run %{ mkdir -p $HOME/.zsh.after }
  run %{ mkdir -p $HOME/.zsh.prompts }
end

def want_to_install? (section)
  puts "Would you like to install configuration files for: #{section}? [y]es, [n]o"
  STDIN.gets.chomp == 'y'
end

def file_operation(files, method = :symlink)
  skip_all = false
  overwrite_all = false
  backup_all = false

  files.each do |f|
    file = f.split('/').last
    source = "#{ENV["PWD"]}/#{f}"
    target = "#{ENV["HOME"]}/.#{file}"

    puts "--------"
    puts "file:   #{file}"
    puts "source: #{source}"
    puts "target: #{target}"

    if File.exists?(target) || File.symlink?(target)
      unless skip_all || overwrite_all || backup_all
        puts "File already exists: #{target}, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all"
        case STDIN.gets.chomp
        when 'o' then overwrite = true when 'b' then backup = true
        when 'O' then overwrite_all = true
        when 'B' then backup_all = true
        when 'S' then skip_all = true
        end
      end
      FileUtils.rm_rf(target) if overwrite || overwrite_all
      run %{ mv "$HOME/.#{file}" "$HOME/.#{file}.backup" } if backup || backup_all
    end

    if method == :symlink
      run %{ ln -s "#{source}" "#{target}" }
    else
      run %{ cp -f "#{source}" "#{target}" }
    end

    # Temporary solution until we find a way to allow customization
    # This modifies zshrc to load all of yadr's zsh extensions.
    # Eventually yadr's zsh extensions should be ported to prezto modules.
    if file == 'zshrc'
      File.open(target, 'a') do |f|
        f.puts('for config_file ($HOME/.yadr/zsh/*.zsh) source $config_file')
      end
    end

  end
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
