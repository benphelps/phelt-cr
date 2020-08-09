require "../token"

module AST
  class Program < Node
    property orig : String?
    property statements : Array(Statement)

    def initialize(@statements)
    end

    def token_literal
      if @statements.size > 0
        return @statements[0].token_literal
      end
      return ""
    end

    def string
      @statements.join("", &.string)
    end
  end
end
