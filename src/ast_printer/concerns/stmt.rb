module AstPrinter::Concerns::Stmt
  def visit_block_stmt(stmt)
    str = ''
    stmt.statements.each do |statement|
      str += "#{statement.accept(self)}\n"
    end
    str
  end

  def visit_class_stmt(stmt)
    str = "(class #{stmt.name.lexeme}"
    str += " < #{stmt.superclass.accept(self)}" if stmt.superclass
    str += "\n"
    stmt.methods.each do |method|
      str += "#{method.accept(self)}\n"
    end
    str + ')'
  end

  def visit_expression_stmt(stmt)
    parenthesize('expression', stmt.expression)
  end

  def visit_function_stmt(stmt)
    str = "(fun #{stmt.name.lexeme}("
    stmt.params.each do |param|
      str += "#{param.lexeme}, "
    end
    str += ")\n"
    stmt.body.each do |body|
      str += "#{body.accept(self)}\n"
    end
    str + ')'
  end

  def visit_if_stmt(stmt)
    str = "(if #{stmt.condition.accept(self)}\n"
    str += "#{stmt.then_branch.accept(self)}\n"
    str += "#{stmt.else_branch.accept(self)}\n" if stmt.else_branch
    str + ')'
  end

  def visit_print_stmt(stmt)
    parenthesize('print', stmt.expression)
  end

  def visit_return_stmt(stmt)
    return "(return)" unless stmt.value
    parenthesize('return', stmt.value)
  end

  def visit_var_stmt(stmt)
    return "(var #{stmt.name.lexeme})" unless stmt.initializer
    parenthesize('var', stmt.name, stmt.initializer)
  end

  def visit_while_stmt(stmt)
    str = "(while #{stmt.condition.accept(self)}\n"
    str += "#{stmt.body.accept(self)}\n"
    str + ')'
  end
end

