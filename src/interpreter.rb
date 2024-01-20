require_relative 'token_type'
require_relative 'expr'
require_relative 'ast_printer'

class Interpreter
  include TokenType

  def interpret(statements)
    value = evaluate(statements)
    print stringify(value)
  rescue RuntimeError => e
    Lox.runtime_error(e)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_unary_expr(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when MINUS
      check_number_operand(expr.operator, right)
      -right
    when BANG
      !truthy?(right)
    end
  end

  def check_number_operand(operator, operand)
    return if operand.is_a?(Numeric)

    raise LoxRuntimeError.new(operator, "Operand must be a number.")
  end

  def check_number_operands(operator, left, right)
    return if left.is_a?(Numeric) && right.is_a?(Numeric)
    raise LoxRuntimeError.new(operator, "Operands must be numbers.")
  end

  def truthy?(object)
    return false if object.nil?
    return false if object == false

    true
  end

  def visit_grouping_expr(expr)
    evaluate(expr.expression)
  end

  def visit_binary_expr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.type
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
      raise RuntimeError.new(expr.operator, "Operands must be two numbers or two strings.")
      end
    when SLASH
      check_number_operands(expr.operator, left, right)
      left / right
    when STAR
      check_number_operands(expr.operator, left, right)
      left * right
    when BANG_EQUAL
      !equal?(left, right)
    when EQUAL_EQUAL
      equal?(left, right)
    end
  end

  def evaluate(expr)
    expr.accept(self)
  end

  def equal?(a, b)
    return true if a.nil? && b.nil?
    return false if a.nil?

    a == b
  end

  def stringify(object)
    return 'nil' if object.nil?

    object.to_s
  end
end
