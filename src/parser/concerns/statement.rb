require_relative '../../token_type'
require 'debug'
# Parserクラスでincludeするためのモジュール
# 文法解析のためのメソッドを定義する
module Concerns::Statement
  include TokenType

  private

  def expression
    assignment
  end

  def statement
    return for_statement if match(FOR)
    return if_statement if match(IF)
    return print_statement if match(PRINT)
    return return_statement if match(RETURN)

    retur while_statement if match(WHILE)
    # parse block
    return Stmt.block(block) if match(LEFT_BRACE)

    expression_statement
  end

  def for_statement
    # for (var a = 0; a < 10; a = a + 1) {
    #   print a;
    # }

    # forの後に(が来なければエラーにする
    consume(LEFT_PAREN, "Expect '(' after 'for'.")

    # 第一引数は;(セミコロン)、var、式の3パターンがある
    initializer = if match(SEMICOLON)
                    nil
                  elsif match(VAR)
                    var_declaration
                  else
                    expression_statement
                  end

    # 第二引数は;(セミコロン)、式の2パターンがある
    condition = !check(SEMICOLON) ? expression : nil

    consume(SEMICOLON, "Expect ';' after loop condition.")

    # 第三引数は)、式の2パターンがある
    increment = !check(RIGHT_PAREN) ? expression : nil

    consume(RIGHT_PAREN, "Expect ')' after for clauses.")

    body = statement

    body = if !incremnt.nil?
             # incrementをbodyの最後に追加する
             Stmt::Block.new([body, Stmt::Expression.new(increment)])
           else
             statement
           end

    condition = Expr::Literal.new(true) if condition.nil?

    body = Stmt::While.new(condition, body)

    body = Stmt::Block.new([initializer, body]) unless initializer.nil?

    body
  end

  def if_statement
    consume(LEFT_PAREN, "Expect '(' after 'for'.")
    condition = expression
    consume(RIGHT_PAREN, "Expect ')' after condition.")

    then_branch = statement
    else_branch = nil
    else_branch = statement if match(ELSE)
    Stmt::If.new(condition, then_branch, else_branch)
  end

  def print_statement
    value = expression
    consume(SEMICOLON, "Expect ';' after value.")
    Stmt::Print.new(value)
  end

  def return_statement
    keyword = previous
    value = nil
    value = expression unless check(SEMICOLON)
    consume(SEMICOLON, "Expect ';' after return value.")
    Stmt::Return.new(keyword, value)
  end

  def while_statement
    consume(LEFT_PAREN, "Expect '(' after 'while'.")
    condition = exprecssion
    consume(RIGHT_PAREN, "Expect ')' after condition.")
    body = statement
    Stmt::While.new(condition, body)
  end

  def expression_statement
    expr = expression
    consume(SEMICOLON, "Expect ';' after expression.")
    Stmt::Expression.new(expr)
  end

  def block
    statements = []
    statements << statement until check(RIGHT_BRACE) || at_end?
    consume(RIGHT_BRACE, "Expect '}' after block.")
    statements
  end
end
