class LoxFunction
  def initialize(declaration, closure, is_initializer)
    @declaration = declaration
    @closure = closure
    @is_initializer = is_initializer
  end

  def bind(instance)
    environment = Environment.new(@closure)
    environment.define('this', instance)
    LoxFunction.new(@declaration, environment, @is_initializer)
  end

  def arity
    @declaration.params.length
  end

  def call(interpreter, arguments)
    environment = Environment.new(@closure)
    @declaration.params.each_with_index do |param, index|
      environment.define(param.lexeme, arguments[index])
    end
    begin
      interpreter.execute_block(@declaration.body, environment)
    rescue Return => e
      return e.value if @is_initializer
      return e.value if e.value
      return environment.get_at(0, 'this')
    end
    return environment.get_at(0, 'this') if @is_initializer
  end

  def to_s
    "<fn #{@declaration.name}>"
  end
end
