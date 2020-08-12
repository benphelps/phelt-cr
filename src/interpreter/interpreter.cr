require "../lexer"
require "../parser"
require "../evaluator"
require "../object"

module Interpreter
  class Interpreter
    property file : Path

    def initialize(@file)
    end

    def run
      input = File.read(@file)
      lexer = Lexer::Lexer.new(input)
      parser = Parser::Parser.new(lexer)

      program = parser.parse_program

      if parser.errors.size > 0
        STDOUT.puts parser.errors.join("\n")
        return 1
      end

      evaluated = Evaluator::Evaluator.new(program).eval

      if evaluated.is_a? PheltObject::Error
        STDOUT.puts evaluated.inspect
        return 1
      end

      return 0
    end
  end
end
