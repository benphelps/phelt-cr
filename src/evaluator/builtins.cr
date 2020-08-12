require "../object/*"
require "../lexer"
require "../parser"

macro define_builtin(name, expected_args, expected_type = nil, &block)
  BUILTINS[{{name}}] = PheltObject::Builtin.new(
    function = PheltObject::BuiltinFunction.new do |args, env|
      if args.size != {{expected_args}}
        return PheltObject::Error.new("Wrong number of arguments, got #{args.size}, expected #{{{expected_args}}}", "", 0, 0)
      end

      first = args[0]
      second = args[1] if args[1]?
      third = args[2] if args[2]?
      args = args[3..]?

      {% if expected_type %}
      unless first.is_a? {{expected_type}}
        return PheltObject::Error.new("First argument to `#{{{name}}}` must be #{{{expected_type}}::TYPE}, got #{first.type}", "", 0, 0)
      else
        {% type = expected_type.resolve.name.downcase.split("::").last %}
        {{type.id}} = first
      end
      {% end %}

      {{ block.body }}

      return ::Evaluator::Evaluator::NULL
    end
  )
end

module Evaluator
  BUILTINS = {} of String => PheltObject::Builtin

  define_builtin("eval", 1, PheltObject::String) do
    parser = Parser::Parser.new(Lexer::Lexer.new(string.value))
    evaluator = ::Evaluator::Evaluator.new(parser.parse_program, env)
    return evaluator.eval
  end

  define_builtin("len", 1) do
    case first
    when PheltObject::String
      return PheltObject::Integer.new(first.value.size.to_i64)
    when PheltObject::Array
      return PheltObject::Integer.new(first.elements.size.to_i64)
    else
      return PheltObject::Error.new("First argument to `len` not supported, got #{first.type}", "", 0, 0)
    end
  end

  define_builtin("first", 1, PheltObject::Array) do
    return array.elements[0] if array.elements.size > 0
  end

  define_builtin("last", 1, PheltObject::Array) do
    return array.elements[array.elements.size - 1] if array.elements.size > 0
  end

  define_builtin("rest", 1, PheltObject::Array) do
    return PheltObject::Array.new(array.elements[1..]) if array.elements.size > 0
  end

  define_builtin("push", 2, PheltObject::Array) do
    array.elements.push(second.as(PheltObject::Object))
    return array
  end

  define_builtin("pop", 1, PheltObject::Array) do
    popped = array.elements.pop
    return popped
  end

  define_builtin("shift", 1, PheltObject::Array) do
    shifted = array.elements.shift
    return shifted
  end

  define_builtin("unshift", 2, PheltObject::Array) do
    array.elements.unshift(second.as(PheltObject::Object))
    return array
  end
end
