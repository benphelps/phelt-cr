require "option_parser"
require "./repl/*"
require "./interpreter"

parser = OptionParser.new do |parser|
  parser.banner = "Usage: phelt [command] [program file]"

  parser.on "-v", "--version", "Show version" do
    STDOUT.puts "version 0.0.1"
    exit(0)
  end

  parser.on "-h", "--help", "Show help" do
    STDOUT.puts parser
    exit(0)
  end

  parser.on "-d", "--debugger", "Interactive Debugger" do
    REPL::Debugger.start
  end

  parser.on "-i", "--interactive", "Interactive REPL" do
    REPL::REPL.start
  end

  parser.unknown_args do |args|
    if args.size > 0
      file = Path[args[0]]
      if File.exists?(file)
        interpreter = Interpreter::Interpreter.new(file)
        exit(interpreter.run)
      else
        STDERR.puts "No file #{file}"
        exit(1)
      end
    else
      STDOUT.puts parser
      exit(1)
    end
  end
end

parser.parse
