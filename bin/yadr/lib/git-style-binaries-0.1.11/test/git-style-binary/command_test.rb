require File.dirname(__FILE__) + "/../test_helper.rb"
require 'git-style-binary/command'

class CommandTest < Test::Unit::TestCase
  context "cmd" do
    setup do
      @c = GitStyleBinary::Command.new
    end

    should "be able to easily work with constraints" do
      assert_equal @c.constraints, []
      @c.constraints << "foo"
      assert_equal @c.constraints, ["foo"]
    end
    
  end
end
