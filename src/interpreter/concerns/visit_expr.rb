module InterPreter::Concerns::VisitExpr
  def visit_assign_expr(expr)
    value = evaluate(expr.value)
    distance = @locals[expr]
    if distance
      @environment.assign_at(distance, expr.name, value)
    else
      @globals.assign(expr.name, value)
    end
    value
  end

  def visit_binary_expr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.type
    when BANG_EQUAL
      !equal?(left, right)
    when EQUAL_EQUAL
      equal?(left, right)
    when GREATER
      check_number_operands(expr.operator, left, right)
      left > right
    when GREATER_EQUAL
      check_number_operands(expr.operator, left, right)
      left >= right
    when LESS
      check_number_operands(expr.operator, left, right)
      left < right
    when LESS_EQUAL
      check_number_operands(expr.operator, left, right)
      left <= right
    when MINUS
      check_number_operands(expr.operator, left, right)
      left - right
    when PLUS
      if left.is_a?(Numeric) && right.is_a?(Numeric)
        left + right
      elsif left.is_a?(String) && right.is_a?(String)
        left + right
      else
        raise RuntimeError.new(expr.operator, 'Operands must be two numbers or two strings.')
      end
    when SLASH
      check_number_operands(expr.operator, left, right)
      left / right
    when STAR
      check_number_operands(expr.operator, left, right)
      left * right
    end
  end

  def visit_call_expr(expr)
    callee = evaluate(expr.callee)
    arguments = expr.arguments.map { |argument| evaluate(argument) }

    if !callee.is_a?
      raise RuntimeError.new(expr.paren, 'Can only call functions and classes.')
    end

    function = callee

    if arguments.length != function.arity
      raise RuntimeError.new(expr.paren, "Expected #{function.arity} arguments but got #{arguments.length}.")
    end

    function.call
  end

  def visit_get_expr(expr)
    object = evaluate(expr.object)
    if object.is_a?(LoxInstance)
      return object.get(expr.name)
    end

    raise RuntimeError.new(expr.name, 'Only instances have properties.')
  end

  def visit_grouping_expr(expr)
    evaluate(expr.expression)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_logical_expr(expr)
    left = evaluate(expr.left)
    if expr.operator.type == OR
      return left if truthy?(left)
    else
      return left unless truthy?(left)
    end
    evaluate(expr.right)
  end

  def visit_set_expr(expr)
    object = evaluate(expr.object)

    if !object.is_a?(LoxInstance)
      raise RuntimeError.new(expr.name, 'Only instances have fields.')
    end

    value = evaluate(expr.value)
  end

  def visit_super_expr(expr)
    distance = @locals[expr]
    superclass = @environment.get_at(distance, 'super')
    object = @environment.get_at(distance - 1, 'this')
    method = superclass.find_method(expr.method.lexeme)

    if !method
      raise RuntimeError.new(expr.method, "Undefined property '#{expr.method.lexeme}'.")
    end

    method.bind(object)
  end

  def visit_this_expr(expr)
    lookup_variable(expr.keyword, expr)
  end

  def visit_unary_expr(expr)
    right = evaluate(expr.right)
    case expr.operator.type
    when BANG
      !truthy?(right)
    when MINUS
      check_number_operand(expr.operator, right)
      -right
    end
  end

  def visit_variable_expr(expr)
    lookup_variable(expr.name, expr)
  end
end
