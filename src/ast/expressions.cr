require "../token"

module AST
  class EmptyExpression < Expression
    property token : Token::Token = Token::EMPTY

    def token_literal
      ""
    end

    def string
      ""
    end
  end

  class ErrorExpression < Expression
    property token : Token::Token
    property error : String

    def initialize(@token, @error)
    end

    def token_literal
      @token.literal
    end

    def string
      error
    end
  end

  class Identifier < Expression
    property token : Token::Token
    property value : String

    def initialize(@token, @value)
    end

    def token_literal
      @token.literal
    end

    def string
      return @value
    end
  end

  class PrefixExpression < Expression
    property token : Token::Token
    property operator : String
    property right : Expression

    def initialize(@token, @operator, @right)
    end

    def token_literal
      @token.literal
    end

    def string
      "(#{@operator}#{@right.string})"
    end
  end

  class InfixExpression < Expression
    property token : Token::Token
    property operator : String
    property left : Expression
    property right : Expression

    def initialize(@token, @operator, @left, @right)
    end

    def token_literal
      @token.literal
    end

    def string
      "(#{left.string} #{@operator} #{@right.string})"
    end
  end

  class AssignmentInfixExpression < Expression
    property token : Token::Token
    property operator : String
    property left : Expression
    property right : Expression

    def initialize(@token, @operator, @left, @right)
    end

    def token_literal
      @token.literal
    end

    def string
      "(#{left.string} #{@operator} #{@right.string})"
    end
  end

  class IfExpression < Expression
    property token : Token::Token
    property condition : Expression
    property consequence : BlockStatement
    property alternative : BlockStatement?

    def initialize(@token, @condition, @consequence, @alternative = nil)
    end

    def token_literal
      @token.literal
    end

    def string
      str = "if#{@condition.string} #{@consequence.string}"
      unless (alternative = @alternative).nil?
        str += " else #{alternative.string}"
      end
      str
    end
  end

  class ForExpression < Expression
    property token : Token::Token
    property initial : AST::Statement
    property condition : Expression
    property final : Expression
    property statement : BlockStatement

    def initialize(@token, @initial, @condition, @final, @statement)
    end

    def token_literal
      @token.literal
    end

    def string
      "for(#{@initial.string};#{@condition.string};#{@final.string} #{@statement.string}"
    end
  end

  class CallExpression < Expression
    property token : Token::Token
    property function : Expression
    property arguments : Array(Expression)

    def initialize(@token, @function, @arguments)
    end

    def token_literal
      @token.literal
    end

    def string
      "#{function.string}(#{arguments.join(", ", &.string)})"
    end
  end

  class IndexExpression < Expression
    property token : Token::Token
    property left : Expression
    property index : Expression

    def initialize(@token, @left, @index)
    end

    def token_literal
      @token.literal
    end

    def string
      "(#{left.string}[#{index.string}])"
    end
  end

  class ObjectAccessExpression < Expression
    property token : Token::Token
    property left : Expression
    property index : Identifier

    def initialize(@token, @left, @index)
    end

    def token_literal
      @token.literal
    end

    def string
      "#{left.string}.#{index.string}"
    end
  end
end
