require_relative 'expr'
require_relative 'token'
require_relative 'token_type'

class AstPrinter
  def main
    # (- 123)
    unary = Expr::Unary.new(
      Token.new(TokenType::MINUS, '-', nil, 1),
      Expr::Literal.new(123)
    )
    # *
    star = Token.new(TokenType::STAR, '*', nil, 1)
    # (group 45.67 )
    grouping = Expr::Grouping.new(
      Expr::Literal.new(45.67)
    )

    # ( * (- 123) (group (- 123)) )
    expression = Expr::Binary.new(
      unary, star, grouping
    )
    print(print_expr(expression))
  end

  def print_expr(expr)
    expr.accept(self)
  end

  # @param expr [Expr.Binary]
  def visit_binary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
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

  # @param expr [Expr.Unary]
  def visit_unary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.right)
  end

  def parenthesize(name, *exprs)
    str = "(#{name}"
    exprs.each do |expr|
      str += " #{expr.accept(self)}"
    end
    str + ')'
  end
end

AstPrinter.new.main
