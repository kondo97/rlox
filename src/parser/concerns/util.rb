require 'debug'
# Parserクラスでincludeするためのモジュール
# 汎用的なメソッドを定義する
module Concerns::Util
  private

  def match(*types)
    types.each do |type|
      if check(type)
        advance
        return true
      end
    end
    false
  end

  # Tokenを消費して、インデックスを1つ進める
  def consume(type, message)
    return advance if check(type)

    error(peek, message)
  end

  def check(type)
    return false if at_end?

    peek.type == type
  end

  def advance
    @current += 1 unless at_end?
    previous
  end

  # 配列の最後のTokenは必ず:EOFになっている
  def at_end?
    peek.type == :EOF
  end

  def peek
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end

  def error(token, message)
    Lox.error(token, message)
    raise ParseError
  end

  def synchronize
    advance
    until at_end?
      return if previous.type == :SEMICOLON

      case peek.type
      when :CLASS, :FUN, :VAR, :FOR, :IF, :WHILE, :PRINT, :RETURN
        return
      end
      advance
    end
  end
end
