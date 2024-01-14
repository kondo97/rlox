require_relative 'token_type'
require_relative 'expr'

class Parser
  include TokenType

  class ParseError < RuntimeError; end

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    expression
  rescue ParseError
    nil
  end

  def expression
    equality
  end

  def equality
    expr = comprison
    while match(BANG_EQUAL, EQUAL_EQUAL)
      operator = previous
      right = comprison
      expr = Expr::Binary.new(expr, operator, right)
    end
    expr
  end

  def match(*types)
    types.each do |type|
      if check(type)
        advance
        return true
      end
    end
    false
  end

  def cousume(type, message)
    return advance if check(type)

    error(peek, message)
  end

  def error(token, message)
    Lox.error(token, message)

    ParseError.new
  end

  def synchronize
    advance
    until is_at_end
      return if previous.type == SEMICOLON

      case peek.type
      when CLASS, FUN, VAR, FOR, IF, WHILE, PRINT, RETURN
        return
      end
      advance
    end
  end

  def check(type)
    return false if is_at_end

    peek.type == type
  end

  def advance
    @current += 1 unless is_at_end
    previous
  end

  def is_at_end
    peek.type == :eOF
  end

  def peek
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end

  def comprison
    expr = term
    while match(GREATER, GREATER_EQUAL, LESS, LESS_EQUAL)
      operator = previous
      right = term
      expr = Expr::Binary.new(expr, operator, right)
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
      operator = previous
      right = unary
      expr = Expr::Binary.new(expr, operator, right)
    end
    expr
  end

  def unary
    if match(BANG, MINUS)
      operator = previous
      right = unary
      return Expr::Unary.new(operator, right)
    end
    primary
  end

  def primary
    return Expr::Literal.new(false) if match(FALSE)
    return Expr::Literal.new(true) if match(TRUE)
    return Expr::Literal.new(nil) if match(NIL)

    # match method consumes the token if it matches
    # so, need to use previous method
    if match(NUMBER, STRING)
      return Expr::Literal.new(previous.literal)
    end

    if match(LEFT_PAREN)
      expr = expression
      consume(RIGHT_PAREN, "Expect ')' after expression.")
      return Expr::Grouping.new(expr)
    end

    raise error(peek, 'Expect expression.')
  end
end
