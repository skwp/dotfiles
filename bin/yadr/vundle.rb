require 'fileutils'
require 'open3'

module Vundle
  class OldVundleError < StandardError
  end

  @vundles_path = File.expand_path File.join(ENV['HOME'], '.vim', '.vundles.local')

  def self.add_plugin_to_vundle(plugin_repo)
    return if contains_vundle? plugin_repo

    vundles = vundles_from_file
    last_bundle_dir = vundles.rindex{ |line| line =~ /^Plugin / }
    last_bundle_dir = last_bundle_dir ? last_bundle_dir+1 : 0
    vundles.insert last_bundle_dir, "Plugin \"#{plugin_repo}\""
    write_vundles_to_file vundles
  end

  def self.remove_plugin_from_vundle(plugin_repo)
    vundles = vundles_from_file
    deleted_value = vundles.reject!{ |line| line =~ /Plugin "#{plugin_repo}"/ }

    write_vundles_to_file vundles

    !deleted_value.nil?
  end

  def self.vundle_list
    vundles_from_file.select{ |line| line =~ /^Plugin .*/ }.map{ |line| line.gsub(/Plugin "(.*)"/, '\1')}
  end

  def self.update_vundle
    cmd = %Q(vim --noplugin -u #{File.join(ENV['HOME'], '.vim', 'vundles.vim')} -N "+set hidden" "+syntax on" +PluginClean +PluginInstall +qall)
    Open3.popen2e(cmd) do |stdin, stdout_err, wait_thr|
      while output_line = stdout_err.gets
        puts output_line
        raise OldVundleError, 'Your version of Vundle (in vim/bundle/vundle) is old, if `rake update` fails please update manually' if output_line.include? 'Unknown function: vundle#begin'
      end
    end
  end

  private
  def self.contains_vundle?(vundle_name)
    FileUtils.touch(@vundles_path) unless File.exists? @vundles_path
    File.read(@vundles_path).include?(vundle_name)
  end

  def self.vundles_from_file
    FileUtils.touch(@vundles_path) unless File.exists? @vundles_path
    File.read(@vundles_path).split("\n")
  end

  def self.write_vundles_to_file(vundles)
    FileUtils.cp(@vundles_path, "#{@vundles_path}.bak")
    vundle_file = File.open(@vundles_path, "w")
    vundle_file.write(vundles.join("\n"))
    vundle_file.close
  end
end
