module AstPrinter::Concerns::Expr
    # @param expr [Expr.Binary]
  def visit_binary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def vsit_call_expr(expr)
    parenthesize('call', expr.callee, expr.paren, *expr.arguments)
  end

  def visit_get_expr(expr)
    parenthesize('get', expr.object, expr.name)
  end

  # @param name [Expr.Grouping]
  def visit_grouping_expr(expr)
    parenthesize('group', expr.expression)
  end

  # @param expr [Expr.Literal]
  def visit_literal_expr(expr)
    return 'nil' if expr.value.nil?

    expr.value.to_s
  end

  def visit_logical_expr(expr)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visit_set_expr(expr)
    parenthesize('set', expr.object, expr.name, expr.value)
  end

  def visit_super_expr(expr)
    parenthesize('super', expr.keyword)
  end

  def visit_this_expr(expr)
    "this"
  end

  # @param expr [Expr.Unary]
  def visit_unary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.right)
  end

  def visit_variable_expr(expr)
    expr.name.lexeme
  end
end
