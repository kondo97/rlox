require_relative '../../token_type'

module Concerns::Declaration
  include TokenType

  private

  def declaration
    return class_declaration if match(CLASS)
    return function('function') if match(FUN)
    return var_declaration if match(VAR)

    # 上記のどれにも当てはまらない場合は式(statement)と判断する
    statement
  rescue ParseError
    synchronize
    nil
  end

  def class_declaration
    name = consume(IDENTIFIER, 'Expect class name.')

    if match(LESS)
      consume(IDENTIFIER, 'Expect superclass name.')
      superclass = Expr::Variable.new(previous)
    end

    consume(LEFT_BRACE, "Expect '{' before class body.")

    methods = []
    methods << function('method') until check(RIGHT_BRACE) || at_end?

    consume(RIGHT_BRACE, "Expect '}' after class body.")

    Stmt::Class.new(name, superclass, methods)
  end

  def var_declaration
    name = consume(IDENTIFIER, 'Expect variable name.')
    initializer = nil
    initializer = expression if match(EQUAL)
    consume(SEMICOLON, "Expect ';' after variable declaration.")
    Stmt::Var.new(name, initializer)
  end

  def function(kind)
    name = consume(IDENTIFIER, "Expect #{kind} name.")
    consume(LEFT_PAREN, "Expect '(' after #{kind} name.")
    parameters = []
    parameters << consume(IDENTIFIER, 'Expect parameter name.') until check(RIGHT_PAREN)
    consume(RIGHT_PAREN, "Expect ')' after parameters.")
    consume(LEFT_BRACE, "Expect '{' before #{kind} body.")
    body = block
    Stmt::Function.new(name, parameters, body)
  end
end
