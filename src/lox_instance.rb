class LoxInstance
  def initialize(klass)
    @klass = klass
    @fields = {}
  end

  def get(name)
    if @fields.key?(name.lexeme)
      @fields[name.lexeme]
    else
      method = @klass.find_method
    return method if method
    raise RuntimeError.new(name, "Undefined property '#{name.lexeme}'.")
  end
  
  def set(name, value)
    @fields[name.lexeme] = value
  end

  def to_s
    "<instance of #{@klass}>"
  end
end
