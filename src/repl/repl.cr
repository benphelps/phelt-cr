require "colorize"
require "../lexer"
require "../parser"
require "../evaluator"
require "../object"

module REPL
  PROMPT = ">> "

  class REPL
    def self.start
      STDOUT.puts "phelt v0.0.1"
      env = PheltObject::Environment.new

      while true
        STDOUT.print ::REPL::PROMPT
        input = gets
        exit if input.nil? # Ctrl+D
        return if !input
        lexer = ::Lexer::Lexer.new(input)
        parser = Parser::Parser.new(lexer)
        program = parser.parse_program

        if parser.errors.size > 0
          parser.errors.each do |error|
            STDERR.puts parser.formatted_error(error)
          end
        else
          evaluator = Evaluator::Evaluator.new(program, env).eval
          STDOUT.puts evaluator.inspect
        end
      end
    end
  end

  class Debugger
    def self.start
      puts "phelt parser debugger"

      while true
        STDOUT.print ::REPL::PROMPT
        input = gets
        exit if input.nil? # Ctrl+D
        return if !input
        lexer = ::Lexer::Lexer.new(input)
        parser = Parser::Parser.new(lexer)
        program = parser.parse_program

        if parser.errors.size > 0
          parser.errors.each do |error|
            STDERR.puts parser.formatted_error(error)
          end
        else
          STDOUT.print ::REPL::PROMPT.colorize(:green)
          STDOUT.puts "#{program.statements.join(",", &.token)} = #{program.string}"
        end
      end
    end
  end
end
