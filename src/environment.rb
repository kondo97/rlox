class Environment
  def initialize
    @enclosing = nil
  end

  def get(name)
    if @values.key?(name.lexeme)
      @values[name.lexeme]
    elsif @enclosing
      @enclosing.get(name)
    else
      raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
    end
  end

  def assign(name, value)
    if @values.key?(name.lexeme)
      @values[name.lexeme] = value
    elsif @enclosing
      @enclosing.assign(name, value)
    else
      raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
    end
  end

  def ancestor(distance)
    environment = self
    distance.times do
      environment = environment.enclosing
    end
    environment
  end

  def getAt(distance, name)
    ancestor(distance).values[name]
  end

  def assignAt(distance, name, value)
    ancestor(distance).values[name] = value
  end

  def to_string
    @values.keys.join(', ')
  end
end
