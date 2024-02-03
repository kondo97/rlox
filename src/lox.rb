# frozen_string_literal: true
#
require_relative './scanner/index'
require_relative './parser/index'
require_relative './ast_printer/index'
require_relative 'token_type'
require_relative './interpreter/index'

class Lox
  attr_accessor :had_error, :had_runtime_error, :interpreter

  def initialize
    @had_error = false
    @had_runtime_error = false
    @interpreter = Interpreter.new
  end

  def main(args)
    # 引数がない場合はエラー
    if args.length > 1
      puts 'Usage: rlox [script]'
      exit 64
    # 引数が1つの場合はスクリプトファイルが指定されたと解釈する
    elsif args.length == 1
      run_file(args[0])
    # 引数が2つ以上の場合はプロンプトを起動する
    else
      run_prompt
    end
  end

  def self.error(token, message)
    if token.type == :EOF
      report(token.line, ' at end', message)
    else
      report(token.line, " at '#{token.lexeme}'", message)
    end
  end

  def self.runtime_error(error)
    puts "#{error.message}\n[line #{error.token.line}]"
    @had_runtime_error = true
  end

  def self.report(line, where, message)
    puts "[line #{line}] Error #{where}: #{message}"
    @had_error = true
  end

  private

  def run_file(path)
    source = File.open(path).read
    run(source)
    exit(65) if @had_error
    exit(70) if @has_runtime_error
  end

  def run_prompt
    print '> '
    loop do
      # getsメソッドはターミナルをコマンド入力待ちの状態にする
      line = gets.chomp
      break if line.nil?

      run(line)
      @had_error = false
    end
  end

  def run(source)
    # ソースからトークンの配列を生成する
    # ex. 例えばソースが "1 + 2"の場合、トークンの配列は下記のようになる
    # [#<Token:0x00000001003994e0 @type=:NUMBER, @lexeme="1", @literal=1.0, @line=1>,
    # #<Token:0x0000000100399490 @type=:EQUAL, @lexeme="=", @literal=nil, @line=1>,
    # #<Token:0x00000001003993f0 @type=:NUMBER, @lexeme="2", @literal=2.0, @line=1>,
    # #<Token:0x00000001003993a0 @type=:EOF, @lexeme="", @literal=nil, @line=1>]
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    # トークンの配列からASTを生成する
    # ex. 例えばASTは下記のようになる
    # [
    # <Stmt::Print:0x000000010492eff0 @expr=#<Expr::Literal:0x0000000104960938 @value="one">>,
    # <Stmt::Print:0x000000010492e4b0 @expr=#<Expr::Literal:0x000000010492e870 @value=true>>,
    # <Stmt::Print:0x000000010492cb60
    #  @expr=#<Expr::Binary:0x000000010492ce30 @left=#<Expr::Literal:0x000000010492dda8 @value=2.0>,
    #  @operator=#<Token:0x00000001075483e8 @type=:PLUS, @lexeme="+", @literal=nil, @line=3>,
    #  @right=#<Expr::Literal:0x000000010492d510 @value=1.0>>>
    # ]
    parser = Parser.new(tokens)
    statements = parser.parse

    return if @had_error

    resolver = Resolver.new(@interpreter)
    resolver.resolve(statements)

    return if @had_error

    # 9.0
    @interpreter.interpret(statements)
  end
end

Lox.new.main(ARGV)
