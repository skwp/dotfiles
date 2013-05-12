require 'fileutils'

module NeoBundle
  @neobundles_path = File.expand_path File.join(ENV['HOME'], '.vim', '.bundles.local')
  def self.add_plugin_to_neobundle(plugin_repo)
    return if contains_neobundle? plugin_repo

    neobundles = neobundles_from_file
    last_bundle_dir = neobundles.rindex{ |line| line =~ /^NeoBundle / }
    neobundles.insert last_bundle_dir+1, "NeoBundle \"#{plugin_repo}\""
    write_neobundles_to_file neobundles
  end

  def self.remove_plugin_from_neobundle(plugin_repo)
    neobundles = neobundles_from_file
    deleted_value = neobundles.reject!{ |line| line =~ /NeoBundle "#{plugin_repo}"/ }

    write_neobundles_to_file neobundles

    !deleted_value.nil?
  end

  def self.neobundle_list
    neobundles_from_file.select{ |line| line =~ /^NeoBundle .*/ }.map{ |line| line.gsub(/NeoBundle "(.*)"/, '\1')}
  end

  def self.update_neobundle
    system "vim --noplugin -u vim/bundles.vim -N \"+set hidden\" \"+syntax on\" +NeoBundleClean +NeoBundleInstall +qall"
  end


  private
  def self.contains_neobundle?(neobundle_name)
    File.read(@neobundles_path).include?(neobundle_name)
  end

  def self.neobundles_from_file
    File.read(@neobundles_path).split("\n")
  end

  def self.write_neobundles_to_file(neobundles)
    FileUtils.cp(@neobundles_path, "#{@neobundles_path}.bak")
    neobundle_file = File.open(@neobundles_path, "w")
    neobundle_file.write(neobundles.join("\n"))
    neobundle_file.close
  end
end
