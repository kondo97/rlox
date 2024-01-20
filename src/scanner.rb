# frozen_string_literal: true

require_relative 'token_type'
require_relative 'token'

class Scanner
  include TokenType
  KEYWORDS = {
    and: AND,
    class: CLASS,
    else: ELSE,
    false: FALSE,
    for: FOR,
    fun: FUN,
    if: IF,
    nil: NIL,
    or: OR,
    print: PRINT,
    return: RETURN,
    super: SUPER,
    this: THIS,
    true: TRUE,
    var: VAR,
    while: WHILE
  }.freeze

  # @source: the source code
  # @tokens: the list of tokens we've scanned
  # @start: the beginning of the current lexeme
  # @current: the current character we're looking at
  # @line: the current line number
  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    until is_at_end
      @start = @current
      scan_token
    end

    @tokens << Token.new(EOF, '', nil, @line)
    @tokens
  end

  private

  def is_at_end
    @current >= @source.length
  end

  def scan_token
    case c = advance
    when '(' then add_token(LEFT_PAREN)
    when ')' then add_token(RIGHT_PAREN)
    when '{' then add_token(LEFT_BRACE)
    when '}' then add_token(RIGHT_BRACE)
    when ',' then add_token(COMMA)
    when '.' then add_token(DOT)
    when '-' then add_token(MINUS)
    when '+' then add_token(PLUS)
    when ';' then add_token(SEMICOLON)
    when '*' then add_token(STAR)
    when '!' then add_token(match('=') ? BANG_EQUAL : BANG)
    when '=' then add_token(match('=') ? EQUAL_EQUAL : EQUAL)
    when '<' then add_token(match('=') ? LESS_EQUAL : LESS)
    when '>' then add_token(match('=') ? GREATER_EQUAL : GREATER)
    when '/'
      if match('/')
        advance while peek != "\n" && !is_at_end
      else
        add_token(SLASH)
      end
    when ' ', "\r", "\t"
    when "\n" then @line += 1
    when '"' then string
    else
      if is_digit(c)
        number
      elsif is_alpha(c)
        identifier
      else
        Lox.error(@line, 'Unexpected character.')
      end
    end
  end

  def advance
    @current += 1
    @source[@current - 1]
  end

  def add_token(type)
    add_tokens(type, nil)
  end

  def add_tokens(type, literal)
    text = @source[@start...@current]
    @tokens << Token.new(type, text, literal, @line)
  end

  def match(expected)
    return false if is_at_end
    # check next character
    # ex) !=, ==, <=, >=
    return false if @source[@current] != expected

    @current += 1
    true
  end

  def peek
    return "\0" if is_at_end

    @source[@current]
  end

  def peek_next
    return "\0" if @current + 1 >= @source.length

    @source[@current + 1]
  end

  def string
    while peek != '"' && !is_at_end
      @line += 1 if peek == "\n"
      advance
    end
    if is_at_end
      Lox.error(@line, 'Unterminated string.')
      return
    end
    # The closing ".
    advance
    # Trim the surrounding quotes.
    value = @source[@start + 1...@current - 1]
    add_tokens(STRING, value)
  end

  def is_digit(c)
    c >= '0' && c <= '9'
  end

  def number
    advance while is_digit(peek)
    if peek == '.' && is_digit(peek_next)
      advance
      advance while is_digit(peek)
    end
    add_tokens(NUMBER, @source[@start...@current].to_f)
  end

  def identifier
    advance while is_alpha_numeric(peek)
    text = @source[@start...@current]
    type = KEYWORDS[text.to_sym] || IDENTIFIER
    add_tokens(type, nil)
  end

  def is_alpha(c)
    (c >= 'a' && c <= 'z') ||
      (c >= 'A' && c <= 'Z') ||
      c == '_'
  end

  def is_alpha_numeric(c)
    is_alpha(c) || is_digit(c)
  end
end
