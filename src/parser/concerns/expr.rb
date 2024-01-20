require_relative '../../token_type'
# Parserクラスでincludeするためのモジュール
# 式に関するメソッドを定義する
# 予約後であるかを順番に確認して、該当すればExpr::xxx.newを返す
# Expr::xxxは、式を表すクラスである
module Concerns::Expr
  include TokenType

  def assignment
    expr = orr
    if match(EQUAL)
      equals = previous
      value = assignment
      if expr.is_a?(Expr::Variable)
        name = expr.name
        return Expr::Assign.new(name, value)
      elsif expr.is_a?(Expr::Get)
        get = expr
        return Expr::Set.new(get.object, get.name, value)
      end
      error(equals, 'Invalid assignment target.')
    end
    expr
  end

  def orr
    expr = andd
    while match(OR)
      operator = previous
      right = andd
      expr = Expr::Logical.new(expr, operator, right)
    end
    expr
  end

  def andd
    expr = equality
    while match(AND)
      operator = previous
      right = equality
      expr = Expr::Logical.new(expr, operator, right)
    end
    expr
  end

  def equality
    expr = comparison
    while match(BANG_EQUAL, EQUAL_EQUAL)
      operator = previous
      right = comprison
      expr = Expr::Binary.new(expr, operator, right)
    end
    expr
  end

  def comparison
    expr = term
    while match(GREATER, GREATER_EQUAL, LESS, LESS_EQUAL)
      operator = previous
      right = term
      expr = Expr.binary(expr, operator, right)
    end
    expr
  end

  def term
    expr = factor
    while match(MINUS, PLUS)
      operator = previous
      right = factor
      expr = Expr::Binary.new(expr, operator, right)
    end
    expr
  end

  def factor
    expr = unary
    while match(SLASH, STAR)
      opperator = previous
      right = unary
      expr = Expr::Binary.new(expr, opperator, right)
    end
    expr
  end

  def unary
    while match(BANG, MINUS)
      operator = previous
      right = unary
      return Expr::Unary.new(operator, right)
    end
    call
  end

  def finish_call(callee)
    arguments = []
    arguments << expression while !check(RIGHT_PAREN) && !at_end?
    paren = consume(RIGHT_PAREN, "Expect ')' after arguments.")
    Expr::Call.new(callee, paren, arguments)
  end

  def call
    expr = primary
    loop do
      expr = finish_call(expr) if match(LEFT_PAREN)
      break unless match(DOT)

      name = consume(IDENTIFIER, 'Expect property name after ".".')
      expr = Expr::Get.new(expr, name)
    end
    expr
  end

  def primary
    return Expr::Literal.new(false) if match(FALSE)
    return Expr::Literal.new(true) if match(TRUE)
    return Expr::Literal.new(nil) if match(NIL)

    return Expr::Literal.new(previous.literal) if match(NUMBER, STRING)

    if match(SUPER)
      keyword = previous
      consume(DOT, "Expect '.' after 'super'.")
      method = consume(IDENTIFIER, 'Expect superclass method name.')
      return Expr::Super.new(keyword, method)
    end

    return Expr.this(previous) if match(THIS)

    return Expr::Variable.new(previous) if match(IDENTIFIER)

    if match(LEFT_PAREN)
      expr = expression
      consume(RIGHT_PAREN, "Expect ')' after expression.")
      return Expr::Grouping.new(expr)
    end

    raise error(peek, 'Expect expression.')
  end
end
