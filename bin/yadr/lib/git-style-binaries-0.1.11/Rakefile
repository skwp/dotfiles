require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "git-style-binaries"
    gem.description = %Q{Ridiculously easy git-style binaries}
    gem.summary =<<-EOF 
    Add git-style binaries to your project easily.
    EOF
    gem.email = "nate@natemurray.com"
    gem.homepage = "http://github.com/jashmenn/git-style-binaries"
    gem.authors = ["Nate Murray"]
    gem.add_dependency 'trollop'
    gem.add_dependency 'shoulda' # for running the tests

    excludes = /(README\.html)/
    gem.files = (FileList["[A-Z]*.*", "{bin,examples,generators,lib,rails,spec,test,vendor}/**/*", 'Rakefile', 'LICENSE*']).delete_if{|f| f =~ excludes}
    gem.extra_rdoc_files = FileList["README*", "ChangeLog*", "LICENSE*"].delete_if{|f| f =~ excludes}
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end


task :default => :test

require 'rake/rdoctask'
require 'yaml'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "git-style-binaries #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :bump => ['version:bump:patch', 'gemspec', 'build']
