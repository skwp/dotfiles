class Test::Unit::TestCase
  def output_should_match(regexp)
    assert_match regexp, @stdout + @stderr
  end
  alias_method :output_matches, :output_should_match

  def stdout_should_match(regexp)
    assert_match regexp, @stdout 
  end
  def stderr_should_match(regexp)
    assert_match regexp, @stderr 
  end
end
