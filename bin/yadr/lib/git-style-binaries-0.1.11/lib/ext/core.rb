class Object
  def returning(value)
    yield(value)
    value
  end unless Object.respond_to?(:returning)
end

class Symbol
  def to_proc
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end
end

class IO
  attr_accessor :use_color
end
