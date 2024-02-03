require_relative './concerns/visit_stmt'
require_relative './concerns/visit_expr'
require_relative '../expr/index'
require_relative '../stmt/index'
require_relative '../lox'
require_relative './environment'
require_relative './clock'
require_relative './lox_callable'
require_relative './lox_function'
require_relative './lox_class'
require_relative './lox_instance'
require_relative './return'
require_relative './lox_runtime_error'

class Interpreter
  include TokenType
  include Stmt::Visitor
  include Expr::Visitor
  include Interpreter::Concerns::VisitStmt
  include Interpreter::Concerns::VisitExpr

  def initialize
    @globals = Environment.new
    @environment = @globals
    @globals.define('clock', Clock.new)
    @globals = {}
  end

  def interpret(statements)
    statements.each do |statement|
      execute(statement)
    end
  rescue RuntimeError => e
    Lox.runtime_error(e)
  end

  def evaluate(expr)
    expr.accept(self)
  end

  def execute(stmt)
    stmt.accept(self)
  end

  def resolve(expr, depth)
    @locals[expr] = depth
  end

  def execute_block(statements, environment)
    previous = @environment
    begin
      @environment = environment
      statements.each do |statement|
        execute(statement)
      end
    ensure
      @environment = previous
    end
  end

  def lookup_variable
    distance = @locals[expr]
    if distance
      @environment.get_at(distance, expr.name.lexeme)
    else
      @globals.get(expr.name)
    end
  end

  def check_number_operand(operator, operand)
    return if operand.is_a?(Numeric)

    raise RuntimeError.new(operator, 'Operand must be a number.')
  end

  def check_number_operands(operator, left, right)
    return if left.is_a?(Numeric) && right.is_a?(Numeric)

    raise RuntimeError.new(operator, 'Operands must be numbers.')
  end

  def truthy?(object)
    return false if object.nil?
    return false if object == false

    true
  end

  def equal?(left, right)
    return true if left.nil? && right.nil?
    return false if left.nil?

    left == right
  end

  def stringify(object)
    return 'nil' if object.nil?
    return object.to_s if object.is_a?(Numeric)

    object.to_s
  end
end
