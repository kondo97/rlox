require_relative '../token_type'
require_relative '../stmt'
require_relative './concerns/index'
require_relative './concerns/declaration'
require_relative './concerns/expr'
require_relative './concerns/statement'
require_relative './concerns/util'

class ParseError < RuntimeError; end

# トークンの配列を受け取り、文の配列を返すためのクラス
class Parser
  include TokenType
  include Concerns::Declaration
  include Concerns::Expr
  include Concerns::Statement
  include Concerns::Util

  # @params tokens [Array<Token>] tokens
  def initialize(tokens)
    @tokens = tokens
    # 配列のインデックス
    # ParseしているTokenの位置を指す
    @current = 0
  end

  # @return [Array<Stmt>]
  def parse
    statements = []
    statements << declaration until at_end?
    statements
  end

  # 例) 以下のようなテキストファイル上のプログラムの場合
  ## print "one";
  ## print true;
  ## print 2 + 1;

  # tokensは、次のような配列で受け取る
  ## [
  ### <Token:0x0000000103718668 @type=:PRINT, @lexeme="print", @literal=nil, @line=1>,
  ### <Token:0x0000000103718618 @type=:STRING, @lexeme="\"one\"", @literal="one", @line=1>,
  ### <Token:0x00000001037185c8 @type=:SEMICOLON, @lexeme=";", @literal=nil, @line=1>,
  ### <Token:0x0000000103718578 @type=:PRINT, @lexeme="print", @literal=nil, @line=2>,
  ### <Token:0x0000000103718528 @type=:TRUE, @lexeme="true", @literal=nil, @line=2>,
  ### <Token:0x00000001037184d8 @type=:SEMICOLON, @lexeme=";", @literal=nil, @line=2>,
  ### <Token:0x0000000103718488 @type=:PRINT, @lexeme="print", @literal=nil, @line=3>,
  ### <Token:0x0000000103718438 @type=:NUMBER, @lexeme="2", @literal=2.0, @line=3>,
  ### <Token:0x00000001037183e8 @type=:PLUS, @lexeme="+", @literal=nil, @line=3>,
  ### <Token:0x0000000103718398 @type=:NUMBER, @lexeme="1", @literal=1.0, @line=3>,
  ### <Token:0x0000000103718348 @type=:SEMICOLON, @lexeme=";", @literal=nil, @line=3>,
  ### <Token:0x00000001037182f8 @type=:EOF, @lexeme="", @literal=nil, @line=4>
  ## ]

  # 結果(statements)は、次のような値になる
  ## [
  ### <Stmt::Print:0x000000010492eff0 @expr=#<Expr::Literal:0x0000000104960938 @value="one">>,
  ### <Stmt::Print:0x000000010492e4b0 @expr=#<Expr::Literal:0x000000010492e870 @value=true>>,
  ### <Stmt::Print:0x000000010492cb60
  ###  @expr=#<Expr::Binary:0x000000010492ce30 @left=#<Expr::Literal:0x000000010492dda8 @value=2.0>,
  ###  @operator=#<Token:0x00000001075483e8 @type=:PLUS, @lexeme="+", @literal=nil, @line=3>,
  ###  @right=#<Expr::Literal:0x000000010492d510 @value=1.0>>>
  ### ]
end
