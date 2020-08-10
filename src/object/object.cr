require "../ast"

module PheltObject
  struct Type
    property value : ::String

    def initialize(@value)
    end
  end

  alias Number = Integer | Float
  alias Object = Integer | Float | Boolean | Error | Null | Return | Function | String | Builtin

  class Integer
    property value : Int64

    def initialize(@value)
    end

    def type
      "number"
    end

    def inspect
      @value.to_s
    end
  end

  class Float
    property value : Float64

    def initialize(@value)
    end

    def type
      "number"
    end

    def inspect
      @value.to_s
    end
  end

  class Boolean
    property value : Bool

    def initialize(@value)
    end

    def type
      "boolean"
    end

    def inspect
      @value.to_s
    end
  end

  class String
    property value : ::String

    def initialize(@value)
    end

    def type
      "string"
    end

    def inspect
      @value.to_s
    end
  end

  class Null
    def type
      "null"
    end

    def inspect
      "null"
    end
  end

  class Return
    property value : Object

    def initialize(@value)
    end

    def type
      "return"
    end

    def inspect
      @value.inspect
    end
  end

  class Error
    property message : ::String
    property pretty : ::String
    property line : Int32
    property column : Int32

    def initialize(@message, @pretty, @line, @column)
    end

    def type
      "error"
    end

    def inspect
      @pretty
    end
  end

  class Function
    property parameters : Array(AST::Identifier)
    property body : AST::BlockStatement
    property env : Environment

    def initialize(@parameters, @body, @env)
    end

    def type
      "function"
    end

    def inspect
      "fn(#{@parameters.join(", ", &.string)})#{@body.string}"
    end
  end

  alias BuiltinFunction = (Array(PheltObject::Object)) -> Object

  class Builtin
    property function : BuiltinFunction

    def initialize(@function)
    end

    def type
      "builtin"
    end

    def inspect
      "builtin function"
    end
  end
end
