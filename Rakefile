require 'pathname'
require 'rake'
require 'yaml'

@answers_file = Pathname.new('answers.yml')
@answers = {}
questions = {
  git_configs: 'git configs (color, aliases)',
  irb_pry_configs: 'irb/pry configs (more colorful)',
  rubygems_config: 'rubygems config (faster/no docs)',
  ctags_config: 'ctags config (better js/ruby support)',
  vimify_command_line_tools: 'vimification of command line tools',
  vim_config: 'vim configuration (highly recommended)',
  zsh_enhancements_and_prezto: 'zsh enhancements & prezto'
}

desc "Hook our dotfiles into system-standard positions."
task :install => [:submodules] do
  installation_mode = @answers_file.exists? :unattended : :interactive

  if installation_mode == :interactive
    puts
    puts "======================================================"
    puts "Welcome to YADR Installation. I'll ask you a few"
    puts "questions about which files to install. Nothing will"
    puts "be overwritten without your consent."
    puts "======================================================"
    puts
  else
    @answers = process_answers_file
  end
  # this has all the runcoms from this directory.
  file_operation(Dir.glob('git/*')) if want_to_install?(:git_configs, installation_mode)
  file_operation(Dir.glob('irb/*')) if want_to_install?(:irb_pry_configs, installation_mode)
  file_operation(Dir.glob('ruby/*')) if want_to_install?(:rubygems_config, installation_mode)
  file_operation(Dir.glob('ctags/*')) if want_to_install?(:ctags_config, installation_mode)
  file_operation(Dir.glob('vimify/*')) if want_to_install?(:vimify_command_line_tools, installation_mode)
  file_operation(Dir.glob('{vim,vimrc}')) if want_to_install?(:vim_config, installation_mode)

  if want_to_install?(:zsh_enhancements_and_prezto, installation_mode)
    install_prezto
  end

  success_msg("installed")
end

desc "Init and update submodules."
task :submodules do
  sh('git submodule update --init')
end

file @answers_file do
  fail "#{@answers_file} already exists; please delete it first." if answers_file_ok?
  write_skeleton_answers_file
end
desc "Create skeleton answers file that says 'yes' to everything"
task :answers => @answers_file

desc "Interactive install"
task :default => 'install'

desc "Unattended install, yes to everything, overwrite files where already existing"
task :unattended_brutal => [:answers, :install]

private
def run(cmd)
  puts
  puts "[Installing] #{cmd}"
  `#{cmd}` unless ENV['DEBUG']
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

def answers_file_ok?
  File.exists? @answers_file
end

def process_answers_file
  unless answers_file_ok?
    fail <<-EOS
Must create valid YAML answers file to install unattended.
Please run `rake unattended:answers` to create the skeleton at ./answers.yml, and then edit it.
This can then be re-used.
EOS
  end
  @answers = YAML.load_file @answers_file
end

def write_skeleton_answers_file
  yaml = {
    git_configs: 'y',
    irb_pry_configs: 'y',
    rubygems_config: 'y',
    ctags_config: 'y',
    vimify_command_line_tools: 'y',
    vim_config: 'y',
    zsh_enhancements_and_prezto: 'y'
  }.to_yaml
  File.open('answers.yml', 'w') do |content|
    content.puts "# Valid answers are y or no for yes or no."
    content.puts yaml
  end
end

def want_to_install? (section, mode)
  if mode == :interactive
    puts "Would you like to install configuration files for: #{questions[:section]}? [y]es, [n]o"
    answer = STDIN.gets.chomp == 'y'
  else
    answer = answers[section] == 'y'
  end
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
