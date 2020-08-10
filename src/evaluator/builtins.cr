require "../object/*"

module Evaluator
  BUILTINS = {
    "__VERSION__" => PheltObject::String.new("Phelt v0.0.1"),
    "len"         => PheltObject::Builtin.new(
      function = PheltObject::BuiltinFunction.new do |args|
        if args.size != 1
          return PheltObject::Error.new("Wrong number of arguments, got #{args.size}, expected 1", "", 0, 0)
        end

        arg = args[0]

        case arg
        when PheltObject::String
          return PheltObject::Integer.new(arg.value.size.to_i64)
        else
          return PheltObject::Error.new("Argument to len not supported, got #{arg.type}", "", 0, 0)
        end

        return PheltObject::Null.new
      end
    ),
  }
end
