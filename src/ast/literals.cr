require "../token"

module AST
  class IntegerLiteral < Expression
    property token : Token::Token
    property value : Int64

    def initialize(@token, @value)
    end

    def token_literal
      @token.literal
    end

    def string
      @token.literal
    end
  end

  class FloatLiteral < Expression
    property token : Token::Token
    property value : Float64

    def initialize(@token, @value)
    end

    def token_literal
      @token.literal
    end

    def string
      @token.literal
    end
  end

  class BooleanLiteral < Expression
    property token : Token::Token
    property value : Bool

    def initialize(@token, @value)
    end

    def token_literal
      @token.literal
    end

    def string
      @token.literal
    end
  end

  class StringLiteral < Expression
    property token : Token::Token
    property value : String

    def initialize(@token, @value)
    end

    def token_literal
      @token.literal
    end

    def string
      @token.literal
    end
  end

  class FunctionLiteral < Expression
    property token : Token::Token
    property parameters : Array(Identifier)
    property body : BlockStatement

    def initialize(@token, @parameters, @body)
    end

    def token_literal
      @token.literal
    end

    def string
      "#{token_literal}(#{@parameters.join(", ", &.string)})#{@body.string}"
    end
  end

  class ArrayLiteral < Expression
    property token : Token::Token
    property elements : Array(Expression)

    def initialize(@token, @elements)
    end

    def token_literal
      @token.literal
    end

    def string
      "[#{@elements.join(", ", &.string)}]"
    end
  end
end
