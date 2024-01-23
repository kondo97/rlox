require_relative './expr/index'
require_relative 'token'
require_relative 'token_type'
reuqire_relative './concerns/expr'
require_relative './concerns/stmt'

class AstPrinter
  # このメソッドは、print_exprメソッドの動作を理解するために定義したもの
  # 実査のインタプリタでは必要ない
  # def sample
  #   # (- 123)
  #   unary = Expr::Unary.new(
  #     Token.new(TokenType::MINUS, '-', nil, 1),
  #     Expr::Literal.new(123)
  #   )
  #   # *
  #   star = Token.new(TokenType::STAR, '*', nil, 1)
  #   # (group 45.67 )
  #   grouping = Expr::Grouping.new(
  #     Expr::Literal.new(45.67)
  #   )
  #
  #   # ( * (- 123) (group (- 123)) )
  #   expression = Expr::Binary.new(
  #     unary, star, grouping
  #   )
  #
  #   # print_exprの引数にExprクラスのインスタンスを
  #   # 渡して実行することで、木構造のデータ(文字列)を出力する
  #   print(print_expr(expression))
  # end
  #
  include AstPrinter::Concerns::Expr
  include AstPrinter::Concerns::Stmt

  def print_expr(expr)
    expr.accept(self)
  end

  def print_stmt(stmt)
    stmn.accept(self)
  end

  def parenthesize(name, *exprs)
    str = "(#{name}"
    exprs.each do |expr|
      str += " #{expr.accept(self)}"
    end
    str + ')'
  end

  def parenthesize2(name, *exprs)
    str = "(#{name}"
    exprs.each do |expr|
      str += " #{expr.accept(self)}"
    end
    str + ')'
  end

  def trans_form(builder, parts)
    str = "(#{builder}"
    parts.each do |part|
      if part.is_a?(Expr)
        str += " #{part.accept(self)}"
      elsif part.is_a?(Stmt)
      str += " #{part.accept(self)}"
      elsif part.is_a?(Token)
        str += " #{part.lexeme}"
      elsif part.is_a?(List)
        trans_form(builder, part)
      else
        str += " #{part}"
      end
    end
  end
end

