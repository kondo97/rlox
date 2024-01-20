class Stmt
  class Block
    def initialize(stmts)
      @stmts = stmts
    end

    def accept(visitor)
      visitor.visit_block_stmt(self)
    end
  end

  class Expression
    def initialize(expr)
      @expr = expr
    end

    def accept(visitor)
      visitor.visit_expression_stmt(self)
    end
  end

  class Function
    def initialize(name, params, body)
      @name = name
      @params = params
      @body = body
    end

    def accept(visitor)
      visitor.visit_function_stmt(self)
    end
  end

  class If
    def initialize(condition, then_branch, else_branch)
      @condition = condition
      @then_branch = then_branch
      @else_branch = else_branch
    end

    def accept(visitor)
      visitor.visit_if_stmt(self)
    end
  end

  class Print
    def initialize(expr)
      @expr = expr
    end

    def accept(visitor)
      visitor.visit_print_stmt(self)
    end
  end

  class Return
    def initialize(keyword, value)
      @keyword = keyword
      @value = value
    end

    def accept(visitor)
      visitor.visit_return_stmt(self)
    end
  end

  class Var
    def initialize(name, initializer)
      @name = name
      @initializer = initializer
    end

    def accept(visitor)
      visitor.visit_var_stmt(self)
    end
  end

  class While
    def initialize(condition, body)
      @condition = condition
      @body = body
    end

    def accept(visitor)
      visitor.visit_while_stmt(self)
    end
  end
end
