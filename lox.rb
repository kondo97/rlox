require_relative "scanner"
# root file for the lox-ruby interpreter
# Usage1(run file): ruby lox.rb [path]
# Usage2(run prompt): ruby lox.rb
class Lox
  has_error = false

  def main(args)
    if args.length > 1
      puts "Usage: rlox [script]"
      exit 64
    elsif args.length == 1
      run_file(args[0])
    else
      run_prompt
    end
  end

  private

  def run_file(path)
    source = File.open(path).read
    run(source)
    exit(65) if has_error
  end

  def run_prompt
    print "> "
    loop do
      line = gets.chomp
      break if line.nil?
      run(line)
      has_error = false
    end
  end

  def run(source)
    loop do
      scanner = Scanner.new(source)
      tokens = scanner.scan_tokens
      tokens.each do |token|
        puts token.to_str
      end
      break
    end
  end

  def self.error(line, message)
    report(line, "", message)
  end

  def self.report(line, where, message)
    puts "[line #{line}] Error #{where}: #{message}"
  end
end

Lox.new.main(ARGV)
