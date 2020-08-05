module PheltObject
  struct Type
    property value : String

    def initialize(@value)
    end
  end

  abstract class Object
    abstract def inspect
  end

  alias Number = Integer | Float

  class Integer < Object
    property value : Int64

    def initialize(@value)
    end

    def type
      INTEGER
    end

    def inspect
      @value.to_s
    end
  end

  class Float < Object
    property value : Float64

    def initialize(@value)
    end

    def type
      FLOAT
    end

    def inspect
      @value.to_s
    end
  end

  class Boolean < Object
    property value : Bool

    def initialize(@value)
    end

    def type
      BOOLEAN
    end

    def inspect
      @value.to_s
    end
  end

  class Null < Object
    def type
      NULL
    end

    def inspect
      "null"
    end
  end

  class Return < Object
    property value : Object

    def initialize(@value)
    end

    def type
      RETURN
    end

    def inspect
      @value.inspect
    end
  end

  INTEGER = Type.new("INTEGER")
  FLOAT   = Type.new("FLOAT")
  BOOLEAN = Type.new("BOOLEAN")
  NULL    = Type.new("NULL")
  RETURN  = Type.new("RETURN")
end
