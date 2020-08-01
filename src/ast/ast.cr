module AST
  abstract class Node
    abstract def token_literal
    abstract def string
  end

  abstract class Statement < Node
  end

  abstract class Expression < Node
  end
end
