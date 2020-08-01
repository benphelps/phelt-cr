require "colorize"
require "../lexer"
require "../parser"

module REPL
  class Debugger
    PROMPT = ">> "

    def self.start
      puts "phelt parser debugger"

      while true
        print PROMPT
        input = gets
        exit if input.nil? # Ctrl+D
        return if !input
        lexer = ::Lexer::Lexer.new(input)
        parser = Parser::Parser.new(lexer)
        program = parser.parse_program

        if parser.errors.size > 0
          print PROMPT.colorize(:red)
          puts parser.errors.join(", ")
        else
          print PROMPT.colorize(:green)
          puts program.string
        end
      end
    end
  end
end
