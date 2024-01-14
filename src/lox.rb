# frozen_string_literal: true

require_relative 'scanner'
require_relative 'parser'
require_relative 'ast_printer'
require_relative 'token_type'
# root file for the lox-ruby interpreter
# Usage1(run file): ruby lox.rb [path]
# Usage2(run prompt): ruby lox.rb
class Lox
  attr_accessor :has_error
  def initialize
    @has_error = false
  end

  def main(args)
    if args.length > 1
      puts 'Usage: rlox [script]'
      exit 64
    elsif args.length == 1
      run_file(args[0])
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

  def self.report(line, where, message)
    puts "[line #{line}] Error #{where}: #{message}"
  end

  private

  def run_file(path)
    source = File.open(path).read
    run(source)
    exit(65) if has_error
  end

  def run_prompt
    print '> '
    loop do
      line = gets.chomp
      break if line.nil?

      run(line)
      false
    end
  end

  def run(source)
    scanner = Scanner.new(source)
    # ex. when source is "1 + 2"...tokens is
    # [#<Token:0x00000001003994e0 @type=:NUMBER, @lexeme="1", @literal=1.0, @line=1>,
    # #<Token:0x0000000100399490 @type=:EQUAL, @lexeme="=", @literal=nil, @line=1>,
    # #<Token:0x00000001003993f0 @type=:NUMBER, @lexeme="2", @literal=2.0, @line=1>,
    # #<Token:0x00000001003993a0 @type=:EOF, @lexeme="", @literal=nil, @line=1>]
    tokens = scanner.scan_tokens

    parser = Parser.new(tokens)
    expression = parser.parse

    return if has_error

    puts AstPrinter.new.print_expr(expression)
  end
end

Lox.new.main(ARGV)
