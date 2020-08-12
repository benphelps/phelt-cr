require "../ast"

module PheltObject
  alias Number = Integer | Float
  alias Object = Integer | Float | Boolean | Error | Null | Return | Function | String | Builtin | Array | Hash
  alias Hashable = Integer | String

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

    def hash_key
      HashKey.new(Integer, value.hash)
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

    def hash_key
      HashKey.new(String, value.hash)
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

  class HashKey
    property type : String.class | Integer.class
    property value : UInt64
    def_hash @type, @value

    def initialize(@type, @value)
    end

    def ==(other)
      other.type == @type && other.value == @value
    end
  end

  class HashPair
    property key : Hashable
    property value : Object
    def_hash @key, @value

    def initialize(@key, @value)
    end
  end

  class Hash
    TYPE = "hash"

    property pairs : ::Hash(HashKey, HashPair)

    def initialize(@pairs)
    end

    def type
      TYPE
    end

    def inspect
      string = @pairs.join(", ") { |key, pair|
        "#{pair.key.inspect}: #{pair.value.inspect}"
      }
      "{#{string}}"
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

  class Do
    TYPE = "do"

    property body : AST::BlockStatement

    def initialize(@body)
    end

    def type
      TYPE
    end

    def inspect
      "do #{@body.string}"
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
