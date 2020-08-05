require "colorize"
require "../lexer"
require "../parser"
require "../evaluator"

module REPL
  PROMPT = ">> "

  class REPL
    def self.start
      puts "phelt v0.0.1"

      while true
        print ::REPL::PROMPT
        input = gets
        exit if input.nil? # Ctrl+D
        return if !input
        lexer = ::Lexer::Lexer.new(input)
        parser = Parser::Parser.new(lexer)
        program = parser.parse_program

        if parser.errors.size > 0
          print ::REPL::PROMPT.colorize(:red)
          puts parser.errors.join(", ")
        else
          evaluator = Evaluator::Evaluator.new(program).eval
          puts evaluator.inspect
        end
      end
    end
  end

  class Debugger
    def self.start
      puts "phelt parser debugger"

      while true
        print ::REPL::PROMPT
        input = gets
        exit if input.nil? # Ctrl+D
        return if !input
        lexer = ::Lexer::Lexer.new(input)
        parser = Parser::Parser.new(lexer)
        program = parser.parse_program

        if parser.errors.size > 0
          print ::REPL::PROMPT.colorize(:red)
          puts parser.errors.join(", ")
        else
          print ::REPL::PROMPT.colorize(:green)
          puts "#{program.statements.join(",", &.token)} = #{program.string}"
        end
      end
    end
  end
end
