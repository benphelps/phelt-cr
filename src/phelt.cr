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

  parser.on "-d", "--debugger", "Show help" do
    REPL::Debugger.start
  end
end
