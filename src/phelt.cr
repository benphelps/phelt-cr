require "option_parser"
require "./repl/*"

OptionParser.parse do |parser|
  parser.banner = "phelt v0.0.1"

  parser.on "-v", "--version", "Show version" do
    puts "version 0.0.1"
    exit
  end

  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end

  parser.on "-d", "--debugger", "Interactive Debugger" do
    REPL::Debugger.start
  end

  parser.on "-i", "--interactive", "Interactive REPL" do
    REPL::REPL.start
  end
end
