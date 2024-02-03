module Interpreter::Concerns::VisitStmt
  def visit_block_stmt(stmt)
    execute_block(stmt.statements, Environment.new(@environment))
  end

  def visit_class_stmt(stmt)
    superclass = nil
    superclass = evaluate(stmt.superclass) if stmt.superclass
    @environment.define(stmt.name.lexeme, nil)
    if stmt.superclass
      @environment = Environment.new(@environment)
      @environment.define('super', superclass)
    end
    methods = {}
    stmt.methods.each do |method|
      function = LoxFunction.new(method, @environment, method.name.lexeme == 'init')
      methods[method.name.lexeme] = function
    end
    klass = LoxClass.new(stmt.name.lexeme, superclass, methods)
    if superclass
      @environment = @environment.enclosing
    end
    @environment.assign(stmt.name, klass)
  end

  def visit_expression_stmt(stmt)
    evaluate(stmt.expression)
  end

  def visit_function_stmt(stmt)
    function = LoxFunction.new(stmt, @environment, false)
    @environment.define(stmt.name.lexeme, function)
  end

  def visit_if_stmt(stmt)
    if truthy?(evaluate(stmt.condition))
      execute(stmt.then_branch)
    else
      execute(stmt.else_branch) if stmt.else_branch
    end
  end

  def visit_print_stmt(stmt)
    value = evaluate(stmt.expression)
    puts stringify(value)
  end

  def visit_return_stmt(stmt)
    value = evaluate(stmt.value) if stmt.value
    raise Return.new(value)
  end

  def visit_var_stmt(stmt)
    value = nil
    value = evaluate(stmt.initializer) if stmt.initializer
    @environment.define(stmt.name.lexeme, value)
  end

  def visit_while_stmt(stmt)
    while truthy?(evaluate(stmt.condition))
      execute(stmt.body)
    end
  end
end
