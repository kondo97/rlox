class LoxClass
  attr_reader :name, :methods
  def initialize(name, methods)
    @name = name
    @methods = methods
  end

  def to_s
    "<class #{@name}>"
  end

  def arity(name)
    method = find_method(name)
    method.arity if method
  end

  def call(instance, name, arguments)
    method = find_method(name)
    raise "Undefined property '#{name}'." unless method
    method.bind(instance).call(arguments)
  end

  private

  def find_method(name)
    @methods[name]
  end
end
