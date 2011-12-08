require 'rubygems'
require 'test/unit'
require 'shoulda'
begin require 'redgreen'; rescue LoadError; end
require 'open3'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
Dir[File.join(File.dirname(__FILE__), "shoulda_macros", "*.rb")].each {|f| require f}
ENV['NO_COLOR'] = "true"

require 'git-style-binary'
GitStyleBinary.run = true

class Test::Unit::TestCase
  def fixtures_dir
    File.join(File.dirname(__FILE__), "fixtures")
  end
end

module RunsBinaryFixtures
  # run the specified cmd returning the string values of [stdout,stderr]
  def bin(cmd)
    stdin, stdout, stderr = Open3.popen3("#{fixtures_dir}/#{cmd}")
    [stdout.read, stderr.read]
  end
end

