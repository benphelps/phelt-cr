require "../ast"

module PheltObject
  struct Type
    property value : ::String

    def initialize(@value)
    end
  end

  alias Number = Integer | Float
  alias Object = Integer | Float | Boolean | Error | Null | Return | Function | String | Builtin | Array

  class Integer
    TYPE = "number"

    property value : Int64

    def initialize(@value)
    end

    def type
      TYPE
    end

    def inspect
      @value.to_s
    end
  end

  class Float
    TYPE = "float"
    property value : Float64

    def initialize(@value)
    end

    def type
      TYPE
    end

    def inspect
      @value.to_s
    end
  end

  class Boolean
    TYPE = "boolean"

    property value : Bool

    def initialize(@value)
    end

    def type
      TYPE
    end

    def inspect
      @value.to_s
    end
  end

  class String
    TYPE = "string"

    property value : ::String

    def initialize(@value)
    end

    def type
      TYPE
    end

    def inspect
      @value.to_s
    end
  end

  class Array
    TYPE = "array"

    property elements : ::Array(Object)

    def initialize(@elements)
    end

    def type
      TYPE
    end

    def inspect
      "[#{elements.join(", ", &.inspect)}]"
    end
  end

  class Null
    TYPE = "null"

    def type
      TYPE
    end

    def inspect
      "null"
    end
  end

  class Return
    TYPE = "return"

    property value : Object

    def initialize(@value)
    end

    def type
      TYPE
    end

    def inspect
      @value.inspect
    end
  end

  class Error
    TYPE = "error"

    property message : ::String
    property pretty : ::String
    property line : Int32
    property column : Int32

    def initialize(@message, @pretty, @line, @column)
    end

    def type
      TYPE
    end

    def inspect
      @pretty
    end
  end

  class Function
    TYPE = "function"

    property parameters : ::Array(AST::Identifier)
    property body : AST::BlockStatement
    property env : Environment

    def initialize(@parameters, @body, @env)
    end

    def type
      TYPE
    end

    def inspect
      "fn(#{@parameters.join(", ", &.string)})#{@body.string}"
    end
  end

  alias BuiltinFunction = (::Array(PheltObject::Object), PheltObject::Environment) -> Object

  class Builtin
    TYPE = "builtin"

    property function : BuiltinFunction

    def initialize(@function)
    end

    def type
      TYPE
    end

    def inspect
      "builtin function"
    end
  end
end
