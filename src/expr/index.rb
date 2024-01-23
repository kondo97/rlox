require_relative 'ast_printer'
require_relative 'interpreter'

# 字句を表現するためのクラス
# 各メソッドはAstPrinterクラスに定義されており、
# acceptを実行することで構文木の要素となる。
class Expr
  module Visitor
    def accept(visitor)
      raise 'override me'
    end
  end

  class Assign
    include Visitor

    attr_reader :name, :value

    def initialize(name, value)
      @name = name
      @value = value
    end

    def accept(visitor)
      visitor.visitAssignExpr(self)
    end
  end

  # 2項式 +, -, *, /, ==, !=, <, <=, >, >=
  class Binary
    include Visitor

    attr_reader :left, :operator, :right

    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end

    def accept(visitor)
      visitor.visit_binary_expr(self)
    end
  end

  class Call
    include Visitor

    attr_reader :callee, :paren, :arguments

    def initialize(callee, paren, arguments)
      @callee = callee
      @paren = paren
      @arguments = arguments
    end

    def accept(visitor)
      visitor.visitCallExpr(self)
    end
  end

  class Get
    include Visitor

    attr_reader :object, :name

    def initialize(object, name)
      @object = object
      @name = name
    end

    def accept
      visitor.visit_get_expr(self)
    end
  end

  # 丸かっこ()
  class Grouping
    include Visitor

    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def accept(visitor)
      visitor.visit_grouping_expr(self)
    end
  end

  # 数、文字列、ブール値
  class Literal
    include Visitor

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def accept(visitor)
      visitor.visit_literal_expr(self)
    end
  end

  class Logical
    include Visitor

    attr_reader :left, :operator, :right

    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end
    
    def accept(visitor)
      visitor.visit_logical_expr(self)
    end
  end

  class Set
    include Visitor

    attr_reader :object, :name, :value

    def initialize(object, name, value)
      @object = object
      @name = name
      @value = value
    end

    def accept(visitor)
      visitor.visit_set_expr(self)
    end
  end

  class Super
    include Visitor

    attr_reader :keyword, :method

    def initiazlie(keyword, method)
      @keyword = keyword
      @method = method
    end

    def accept(visitor)
      visitor.visit_super_expr(self)
    end
  end

  class This
    include Visitor

    attr_reader :keyword

    def initialize(keyword)
      @keyword = keyword
    end

    def accept(visitor)
      visitor.visit_this_expr(self)
    end
  end

  # 単項式
  class Unary
    include Visitor

    attr_reader :operator, :right

    def initialize(operator, right)
      @operator = operator
      @right = right
    end

    def accept(visitor)
      visitor.visit_unary_expr(self)
    end
  end

  # 変数
  class Variable
    include Variable

    attr_reader :name

    def initiazlie(name)
      @name = name
    end

    def accept(visitor)
      visitor.visit_variable_expr(self)
    end
  end
end
