class Resolver
  FUNCTION_TYPE = {
    NONE: 0,
    FUNCTION: 1,
    INITIALIZER: 2,
    METHOD: 3
  }.freeze

  CLASS_TYPE = {
    NONE: 0,
    CLASS: 1,
    SUBCLASS: 2
  }.freeze

  def initialize(interpreter)
    @interpreter = interpreter
    @scopes = []
    @current_function = FunctionType::NONE
    @current_class = ClassType::NONE
  end

  def resolve(statements)
    statements.each { |stmt| resolve_stmt(stmt) }
  end

  # 以下、stmtのacceptメソッドから呼ばれるメソッド

  def visit_block_stmt(stmt)
    begin_scope
    resolve(stmt.statements)
    end_scope
  end

  def visit_class_stmt(stmt)
    declare(stmt.name)
    define(stmt.name)
    resolve_class(stmt)
  end

  def visit_expression_stmt(stmt)
    resolve_expr(stmt.expr)
  end

  def visit_function_stmt(stmt)
    declare(stmt.name)
    define(stmt.name)
    resolve_function(stmt, FUNCTION_TYPE[:FUNCTION])
  end

  def visit_if_stmt(stmt)
    resolve_expr(stmt.condition)
    resolve_stmn(stmt.then_branch)
    resolve_stmn(stmt.else_branch) if stmt.else_branch
  end

  def visit_print_stmt(stmt)
    resolve_expr(stmt.expr)
  end

  def visit_return_stmt(stmt)
    resolve_expr(stmt.value) if stmt.value
    if @current_function == FUNCTION_TYPE[:NONE]
      Lox.error(stmt.keyword, 'Cannot return from top-level code.')
    end
  end

  def visit_var_stmt(stmt)
    declare(stmt.name)
    resolve_expr(stmt.initializer) if stmt.initializer
    define(stmt.name)
  end

  def visit_while_stmt(stmt)
    resolve_expr(stmt.condition)
    resolve_stmn(stmt.body)
  end

  def visit_assign_expr(expr)
    resolve_expr(expr.value)
    resolve_local(expr, expr.name)
  end

  def visit_binary_expr(expr)
    resolve_expr(expr.left)
    resolve_expr(expr.right)
  end

  def visit_call_expr(expr)
    resolve_expr(expr.callee)
    expr.arguments.each { |arg| resolve_expr(arg) }
  end

  def visit_get_expr(expr)
    resolve_expr(expr.object)
  end

  def visit_grouping_expr(expr)
    resolve_expr(expr.expression)
  end

  def visit_literal_expr(_expr)
    # Do nothing.
  end

  def visit_logical_expr(expr)
    resolve_expr(expr.left)
    resolve_expr(expr.right)
  end

  def visit_set_expr(expr)
    resolve_expr(expr.value)
    resolve_expr(expr.object)
  end

  def visit_super_expr(expr)
    if @current_class == CLASS_TYPE[:NONE]
      Lox.error(expr.keyword, 'Cannot use "super" outside of a class.')
    elsif @current_class != CLASS_TYPE[:SUBCLASS]
      Lox.error(expr.keyword, 'Cannot use "super" in a class with no superclass.')
    end
    resolve_local(expr, expr.keyword)
  end

  def visit_this_expr(expr)
    if @current_class == CLASS_TYPE[:NONE]
      Lox.error(expr.keyword, 'Cannot use "this" outside of a class.')
      return
    end
    resolve_local(expr, expr.keyword)
  end

  def visit_unary_expr(expr)
    resolve_expr(expr.right)
  end

  def visit_variable_expr(expr)
    return if @scopes.empty?
    if @scopes.last[expr.name.lexeme] == false
      Lox.error(expr.name, 'Cannot read local variable in its own initializer.')
    end
    resolve_local(expr, expr.name)
  end

  private

  def resolve_stmn(stmt)
    stmt.accept(self)
  end

  def resolve_expr(expr)
    expr.accept(self)
  end

  def resolve_function(function, type)
    enclosing_function = @current_function
    @current_function = type
    begin_scope
    function.params.each do |param|
      declare(param)
      define(param)
    end
    resolve(function.body)
    end_scope
    @current_function = enclosing_function
  end

  def begin_scope
    @scopes.push({})
  end

  def end_scope
    @scopes.pop
  end

  def declare
    return if @scopes.empty?
    scope = @scopes.last
    if scope[name.lexeme]
      Lox.error(name, 'Variable with this name already declared in this scope.')
    end
    scope[name.lexeme] = false
  end

  def define(name)
    return if @scopes.empty?
    @scopes.last[name.lexeme] = true
  end

  def resolve_local(expr, name)
    @scopes.reverse.each_with_index do |scope, i|
      if scope[name.lexeme]
        @interpreter.resolve(expr, i)
        return
      end
    end
  end
end
