require 'rake'

desc "Hook our dotfiles into system-standard positions."
task :install => :submodules do
  linkables = Dir.glob('git/*')
  linkables += Dir.glob('irb/*')
  linkables += Dir.glob('{vim,vimrc}')
  linkables += Dir.glob('zsh/zshrc')

  skip_all = false
  overwrite_all = false
  backup_all = false

  linkables.each do |linkable|
    overwrite = false
    backup = false

    file = linkable.split('/').last
    target = "#{ENV["HOME"]}/.#{file}"

    puts "--------"
    puts "file:   #{file}"
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
      `mv "$HOME/.#{file}" "$HOME/.#{file}.backup"` if backup || backup_all
    end
    `ln -s "$PWD/#{linkable}" "#{target}"`
  end
end

desc "Init and update submodules."
task :submodules do
  sh("git submodule init")
  sh("git submodule update")
end

task :default => 'install'
