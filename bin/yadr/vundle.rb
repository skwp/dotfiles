require 'fileutils'

module Vundle
  @vundles_path = File.expand_path File.join(ENV['HOME'], '.vim', '.vundles.local')
  def self.add_plugin_to_vundle(plugin_repo)
    return if contains_vundle? plugin_repo

    vundles = vundles_from_file
    last_bundle_dir = vundles.rindex{ |line| line =~ /^Bundle / }
    vundles.insert last_bundle_dir+1, "Bundle \"#{plugin_repo}\""
    write_vundles_to_file vundles
  end

  def self.remove_plugin_from_vundle(plugin_repo)
    vundles = vundles_from_file
    deleted_value = vundles.reject!{ |line| line =~ /Bundle "#{plugin_repo}"/ }

    write_vundles_to_file vundles

    !deleted_value.nil?
  end

  def self.vundle_list
    vundles_from_file.select{ |line| line =~ /^Bundle .*/ }.map{ |line| line.gsub(/Bundle "(.*)"/, '\1')}
  end

  def self.update_vundle
    system "vim --noplugin -u vim/vundles.vim -N \"+set hidden\" \"+syntax on\" +BundleClean +BundleInstall +qall"
  end


  private
  def self.contains_vundle?(vundle_name)
    File.read(@vundles_path).include?(vundle_name)
  end

  def self.vundles_from_file
    File.read(@vundles_path).split("\n")
  end

  def self.write_vundles_to_file(vundles)
    FileUtils.cp(@vundles_path, "#{@vundles_path}.bak")
    vundle_file = File.open(@vundles_path, "w")
    vundle_file.write(vundles.join("\n"))
    vundle_file.close
  end
end
