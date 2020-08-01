require "../token"

module AST
  class LetStatement < Statement
    property token : Token::Token
    property name : Identifier
    property value : Expression

    def initialize(@token, @name, @value)
    end

    def token_literal
      @token.literal
    end

    def string
      "#{token_literal} #{@name.string} = #{@value.string};"
    end
  end

  class ReturnStatement < Statement
    property token : Token::Token
    property return_value : Expression

    def initialize(@token, @return_value)
    end

    def token_literal
      @token.literal
    end

    def string
      "#{token_literal} #{return_value.string};"
    end
  end

  class ExpressionStatement < Statement
    property token : Token::Token
    property expression : Expression

    def initialize(@token, @expression)
    end

    def token_literal
      @token.literal
    end

    def string
      @expression.string
    end
  end

  class BlockStatement < Statement
    property token : Token::Token
    property statements : Array(Statement)

    def initialize(@token, @statements)
    end

    def token_literal
      @token.literal
    end

    def string
      "{ #{@statements.join("", &.string)} }"
    end
  end
end
