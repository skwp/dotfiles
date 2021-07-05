require 'fileutils'

module VimPlug
  @bundles_path = File.expand_path File.join(ENV['HOME'], '.vim', '.local.bundles')
  def self.add_plugin_to_bundles(plugin_repo)
    return if contains_bundle? plugin_repo

    bundles = bundles_from_file
    last_bundle_dir = bundles.rindex{ |line| line =~ /^Plug / }
    last_bundle_dir = last_bundle_dir ? last_bundle_dir+1 : 0
    bundles.insert last_bundle_dir, "Plug '#{plugin_repo}'"
    write_bundles_to_file bundles
  end

  def self.remove_plugin_from_bundles(plugin_repo)
    bundles = bundles_from_file
    deleted_value = bundles.reject!{ |line| line =~ /Plug '#{plugin_repo}'/ }

    write_bundles_to_file bundles

    !deleted_value.nil?
  end

  def self.bundle_list
    bundles_from_file.select{ |line| line =~ /^Plug .*/ }.map{ |line| line.gsub(/Plug "(.*)"/, '\1')}
  end

  def self.update_bundles
    system "vim --noplugin -u #{ENV['HOME']}/.vim/plugins.d/main.vim -N \"+set hidden\" \"+syntax on\" \"+let g:session_autosave = 'no'\" +PlugClean +PlugInstall! +qall"
  end


  private
  def self.contains_bundle?(bundle_name)
    FileUtils.touch(@bundles_path) unless File.exists? @bundles_path
    File.read(@bundles_path).include?(bundle_name)
  end

  def self.bundles_from_file
    FileUtils.touch(@bundles_path) unless File.exists? @bundles_path
    File.read(@bundles_path).split("\n")
  end

  def self.write_bundles_to_file(bundles)
    FileUtils.cp(@bundles_path, "#{@bundles_path}.bak")
    bundle_file = File.open(@bundles_path, "w")
    bundle_file.write(bundles.join("\n"))
    bundle_file.close
  end
end
