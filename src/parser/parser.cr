require "debug"

require "../ast/*"
require "../lexer"
require "../token"

module Parser
  alias PrefixParser = -> AST::Expression
  alias InfixParser = (AST::Expression) -> AST::Expression

  enum Precedences
    Lowest       # none
    Assignment   # =, +=, -=, etc
    Equals       # ==
    LessGreater  # > or <
    Sum          # +, -
    Product      # *
    Prefix       # -X or !X
    Call         # myFunction(X)
    Index        # array[index]
    ObjectAccess # hash.access
  end

  class Parser
    property errors : Array(Tuple(Token::Token, String)) = [] of Tuple(Token::Token, String)

    @cur_token : Token::Token = Token::ILLEGAL
    @peek_token : Token::Token = Token::ILLEGAL

    @prefix_parsers = {} of Token::Type => PrefixParser
    @infix_parsers = {} of Token::Type => InfixParser

    @precedences = {
      Token::DECREMENT.type       => Precedences::Assignment,
      Token::INCREMENT.type       => Precedences::Assignment,
      Token::ASSIGN.type          => Precedences::Assignment,
      Token::PLUS_ASSIGN.type     => Precedences::Assignment,
      Token::MINUS_ASSIGN.type    => Precedences::Assignment,
      Token::SLASH_ASSIGN.type    => Precedences::Assignment,
      Token::ASTERISK_ASSIGN.type => Precedences::Assignment,
      Token::EQ.type              => Precedences::Equals,
      Token::NOT_EQ.type          => Precedences::Equals,
      Token::LT.type              => Precedences::LessGreater,
      Token::GT.type              => Precedences::LessGreater,
      Token::LT_EQ.type           => Precedences::LessGreater,
      Token::GT_EQ.type           => Precedences::LessGreater,
      Token::PLUS.type            => Precedences::Sum,
      Token::MINUS.type           => Precedences::Sum,
      Token::SLASH.type           => Precedences::Product,
      Token::ASTERISK.type        => Precedences::Product,
      Token::MODULUS.type         => Precedences::Product,
      Token::LPAREN.type          => Precedences::Call,
      Token::LBRACKET.type        => Precedences::Index,
      Token::PERIOD.type          => Precedences::ObjectAccess,
    } of Token::Type => Precedences

    def initialize(@lexer : Lexer::Lexer)
      register_parser_identifier
      register_parser_integer_literal
      register_parser_float_literal
      register_parser_boolean_literal
      register_parser_null_literal
      register_parser_string_literal
      register_parser_prefix_expression
      register_parser_infix_expression
      register_parser_assignment_infix_expression
      register_parser_indecrement_expression
      register_parser_grouped_expression
      register_parser_if_expression
      register_parser_function_literal
      register_parser_do_literal
      register_parser_array_literal
      register_parser_array_index
      register_parser_hash_literal
      register_parser_object_access
      register_parser_for_expression
      register_parser_while_expression

      register_parser_call_expression

      next_token
      next_token
    end

    def next_token
      @cur_token = @peek_token
      @peek_token = @lexer.next_token
    end

    def parse_program
      program = AST::Program.new([] of AST::Statement)
      program.orig = @lexer.input
      while @cur_token.type != Token::EOF.type
        statement = parse_statement()
        program.statements << statement if statement.is_a? AST::Statement
        next_token
      end
      program
    end

    def parse_statement
      case @cur_token.type
      when Token::LET.type
        return parse_let_statement()
      when Token::CONST.type
        return parse_const_statement()
      when Token::RETURN.type
        return parse_return_statement()
      when Token::BREAK.type
        return parse_break_statement()
      else
        return parse_expression_statement()
      end
    end

    def parse_expression_statement
      token = @cur_token
      expression = parse_expression(Precedences::Lowest)

      while peek_token_is?(Token::SEMICOLON)
        next_token
      end

      return AST::ExpressionStatement.new(token, expression)
    end

    def parse_expression(precedence : Precedences)
      if !@prefix_parsers.has_key?(@cur_token.type)
        @errors << {@cur_token, "Unexpected #{@cur_token.type}"} if @cur_token.is_a? Token::EOF
        return AST::EmptyExpression.new
      end
      prefix = @prefix_parsers[@cur_token.type]
      left_expression = prefix.call

      while !peek_token_is?(Token::SEMICOLON) && precedence < peek_precedence
        if !@infix_parsers.has_key?(@peek_token.type)
          return left_expression
        end

        infix = @infix_parsers[@peek_token.type]

        next_token
        left_expression = infix.call(left_expression)
      end

      return left_expression
    end

    def register_parser_prefix_expression
      parser = PrefixParser.new do
        token = @cur_token
        operator = @cur_token.literal
        next_token
        right = parse_expression(Precedences::Prefix)
        AST::PrefixExpression.new(
          token,
          operator,
          right
        )
      end
      @prefix_parsers[Token::DECREMENT.type] = parser
      @prefix_parsers[Token::INCREMENT.type] = parser
      @prefix_parsers[Token::BANG.type] = parser
      @prefix_parsers[Token::MINUS.type] = parser
    end

    def register_parser_identifier
      parser = PrefixParser.new do
        AST::Identifier.new(token = @cur_token, value = @cur_token.literal)
      end
      @prefix_parsers[Token::IDENT.type] = parser
    end

    def register_parser_integer_literal
      parser = PrefixParser.new do
        token = @cur_token
        value = @cur_token.literal.to_i64

        unless value
          @errors << {@cur_token, "could not parse #{@cur_token.literal} as an Int64"}
          return AST::ErrorExpression.new(token, @errors.last)
        end

        AST::IntegerLiteral.new(token, value)
      end

      @prefix_parsers[Token::INT.type] = parser
    end

    def register_parser_float_literal
      parser = PrefixParser.new do
        token = @cur_token
        value = @cur_token.literal.to_f

        unless value
          @errors << {@cur_token, "could not parse #{@cur_token.literal} as an Float64"}
          return AST::ErrorExpression.new(token, @errors.last)
        end

        AST::FloatLiteral.new(token, value)
      end

      @prefix_parsers[Token::FLOAT.type] = parser
    end

    def register_parser_boolean_literal
      parser = PrefixParser.new do
        token = @cur_token
        value = @cur_token.type == Token::TRUE.type

        AST::BooleanLiteral.new(token, value)
      end

      @prefix_parsers[Token::TRUE.type] = parser
      @prefix_parsers[Token::FALSE.type] = parser
    end

    def register_parser_null_literal
      parser = PrefixParser.new do
        token = @cur_token
        value = @cur_token.type == Token::NULL.type

        AST::NullLiteral.new(token)
      end

      @prefix_parsers[Token::NULL.type] = parser
    end

    def register_parser_string_literal
      parser = PrefixParser.new do
        AST::StringLiteral.new(token = @cur_token, value = @cur_token.literal)
      end
      @prefix_parsers[Token::STRING.type] = parser
    end

    def register_parser_array_literal
      parser = PrefixParser.new do
        AST::ArrayLiteral.new(token = @cur_token, elements = parse_expression_list(Token::RBRACKET))
      end
      @prefix_parsers[Token::LBRACKET.type] = parser
    end

    def register_parser_array_index
      parser = InfixParser.new do |left|
        token = @cur_token
        next_token
        index = parse_expression(Precedences::Lowest)

        if !expect_peek(Token::RBRACKET)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        AST::IndexExpression.new(token = @cur_token, left, index)
      end
      @infix_parsers[Token::LBRACKET.type] = parser
    end

    def register_parser_hash_literal
      parser = PrefixParser.new do
        token = @cur_token
        pairs = {} of AST::Expression => AST::Expression

        while !peek_token_is?(Token::RBRACE)
          next_token

          key = parse_expression(Precedences::Lowest)

          if !expect_peek(Token::COLON)
            return AST::ErrorExpression.new(@cur_token, @errors.last)
          end

          next_token

          value = parse_expression(Precedences::Lowest)

          pairs[key] = value

          if !peek_token_is?(Token::RBRACE) && !expect_peek(Token::COMMA)
            return AST::ErrorExpression.new(@cur_token, @errors.last)
          end
        end

        if !expect_peek(Token::RBRACE)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        AST::HashLiteral.new(token, pairs)
      end
      @prefix_parsers[Token::LBRACE.type] = parser
    end

    def register_parser_object_access
      parser = InfixParser.new do |left|
        token = @cur_token

        next_token
        index = AST::Identifier.new(@cur_token, @cur_token.literal)

        if !peek_token_is?(Token::LPAREN)
          return AST::ObjectAccessExpression.new(token, left, index)
        end

        next_token

        params = parse_expression_list(Token::RPAREN)
        return AST::ObjectCallExpression.new(token, left, index, params)
      end
      @infix_parsers[Token::PERIOD.type] = parser
    end

    def register_parser_infix_expression
      parser = InfixParser.new do |left|
        token = @cur_token
        operator = @cur_token.literal
        precedence = cur_precedence
        next_token
        right = parse_expression(precedence)
        AST::InfixExpression.new(token, operator, left, right)
      end

      @infix_parsers[Token::PLUS.type] = parser
      @infix_parsers[Token::MINUS.type] = parser
      @infix_parsers[Token::SLASH.type] = parser
      @infix_parsers[Token::ASTERISK.type] = parser
      @infix_parsers[Token::MODULUS.type] = parser
      @infix_parsers[Token::EQ.type] = parser
      @infix_parsers[Token::NOT_EQ.type] = parser
      @infix_parsers[Token::LT.type] = parser
      @infix_parsers[Token::GT.type] = parser
      @infix_parsers[Token::LT_EQ.type] = parser
      @infix_parsers[Token::GT_EQ.type] = parser
    end

    def register_parser_assignment_infix_expression
      parser = InfixParser.new do |left|
        token = @cur_token
        operator = @cur_token.literal
        precedence = cur_precedence
        next_token
        right = parse_expression(precedence)
        AST::AssignmentInfixExpression.new(token, operator, left, right)
      end

      @infix_parsers[Token::ASSIGN.type] = parser
      @infix_parsers[Token::PLUS_ASSIGN.type] = parser
      @infix_parsers[Token::MINUS_ASSIGN.type] = parser
      @infix_parsers[Token::SLASH_ASSIGN.type] = parser
      @infix_parsers[Token::ASTERISK_ASSIGN.type] = parser
    end

    def register_parser_indecrement_expression
      parser = InfixParser.new do |left|
        token = @cur_token
        operator = @cur_token.literal
        precedence = cur_precedence
        next_token
        AST::InDecrementExpression.new(token, operator, left)
      end

      @infix_parsers[Token::DECREMENT.type] = parser
      @infix_parsers[Token::INCREMENT.type] = parser
    end

    def register_parser_grouped_expression
      parser = PrefixParser.new do
        next_token
        exp = parse_expression(Precedences::Lowest)
        if !expect_peek(Token::RPAREN)
          return AST::EmptyExpression.new
        end
        exp
      end

      @prefix_parsers[Token::LPAREN.type] = parser
    end

    def register_parser_if_expression
      parser = PrefixParser.new do
        token = @cur_token

        if !expect_peek(Token::LPAREN)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        next_token

        condition = parse_expression(Precedences::Lowest)

        if !expect_peek(Token::RPAREN)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        if !expect_peek(Token::LBRACE)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        consequence = parse_block_statement()

        if peek_token_is?(Token::ELSE)
          next_token
          if !expect_peek(Token::LBRACE)
            return AST::ErrorExpression.new(@cur_token, @errors.last)
          end

          alternative = parse_block_statement()

          return AST::IfExpression.new(
            token,
            condition,
            consequence,
            alternative
          )
        end

        AST::IfExpression.new(
          token,
          condition,
          consequence
        )
      end

      @prefix_parsers[Token::IF.type] = parser
    end

    def register_parser_for_expression
      parser = PrefixParser.new do
        token = @cur_token

        if !expect_peek(Token::LPAREN)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        next_token

        initial = parse_statement()

        if !initial.is_a? AST::Statement
          @errors << {token, "Expected statement"}
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        next_token

        condition = parse_expression(Precedences::Lowest)

        next_token
        next_token

        final = parse_expression(Precedences::Lowest)

        if !expect_peek(Token::RPAREN)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        next_token

        statement = parse_block_statement()

        AST::ForExpression.new(
          token,
          initial,
          condition,
          final,
          statement
        )
      end

      @prefix_parsers[Token::FOR.type] = parser
    end

    def register_parser_while_expression
      parser = PrefixParser.new do
        token = @cur_token

        if !expect_peek(Token::LPAREN)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        next_token

        condition = parse_expression(Precedences::Lowest)

        if !expect_peek(Token::RPAREN)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        next_token

        statement = parse_block_statement()

        AST::WhileExpression.new(
          token,
          condition,
          statement
        )
      end

      @prefix_parsers[Token::WHILE.type] = parser
    end

    def register_parser_function_literal
      parser = PrefixParser.new do
        token = @cur_token
        if !expect_peek(Token::LPAREN)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        parameters = parse_function_parameters

        if !expect_peek(Token::LBRACE)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        body = parse_block_statement

        AST::FunctionLiteral.new(token, parameters, body)
      end

      @prefix_parsers[Token::FUNCTION.type] = parser
    end

    def register_parser_do_literal
      parser = PrefixParser.new do
        token = @cur_token
        if !expect_peek(Token::LBRACE)
          return AST::ErrorExpression.new(@cur_token, @errors.last)
        end

        body = parse_block_statement

        AST::DoLiteral.new(token, body)
      end

      @prefix_parsers[Token::DO.type] = parser
    end

    def register_parser_call_expression
      parser = InfixParser.new do |function|
        AST::CallExpression.new(@cur_token, function, parse_expression_list(Token::RPAREN))
      end

      @infix_parsers[Token::LPAREN.type] = parser
    end

    def parse_expression_list(end_token : Token::Token)
      arguments = [] of AST::Expression

      if peek_token_is?(end_token)
        next_token
        return arguments
      end

      next_token
      arguments << parse_expression(Precedences::Lowest)

      while peek_token_is?(Token::COMMA)
        next_token
        next_token
        arguments << parse_expression(Precedences::Lowest)
      end

      if !expect_peek(end_token)
        return [] of AST::Expression
      end

      return arguments
    end

    def parse_function_parameters
      identifiers = [] of AST::Identifier

      if peek_token_is?(Token::RPAREN)
        next_token
        return identifiers
      end

      next_token

      if (@cur_token.type != Token::IDENT.type)
        errors << {@cur_token, "Unexpected argument type #{@cur_token.type}, expected IDENT"}
      else
        identifiers << AST::Identifier.new(@cur_token, @cur_token.literal)
      end

      while peek_token_is?(Token::COMMA)
        next_token
        next_token

        if (@cur_token.type != Token::IDENT.type)
          errors << {@cur_token, "Unexpected argument type #{@cur_token.type}, expected IDENT"}
        else
          identifiers << AST::Identifier.new(@cur_token, @cur_token.literal)
        end
      end

      if !expect_peek(Token::RPAREN)
        AST::ErrorExpression.new(@cur_token, @errors.last)
      end

      identifiers
    end

    def parse_block_statement
      block = AST::BlockStatement.new(
        @cur_token,
        [] of AST::Statement
      )
      next_token

      while !cur_token_is?(Token::RBRACE) && !cur_token_is?(Token::EOF)
        statement = parse_statement()
        block.statements << statement if statement.is_a? AST::Statement
        next_token
      end

      block
    end

    def parse_let_statement
      token = @cur_token

      return AST::ErrorExpression.new(@cur_token, @errors.last) if !expect_peek(Token::IDENT)

      name = AST::Identifier.new(
        token = @cur_token,
        value = @cur_token.literal
      )

      return AST::ErrorExpression.new(@cur_token, @errors.last) if !expect_peek(Token::ASSIGN)

      next_token

      value = parse_expression(Precedences::Lowest)

      if peek_token_is?(Token::SEMICOLON)
        next_token
      end

      return AST::LetStatement.new(token, name, value)
    end

    def parse_const_statement
      token = @cur_token

      return AST::ErrorExpression.new(@cur_token, @errors.last) if !expect_peek(Token::IDENT)

      name = AST::Identifier.new(
        token = @cur_token,
        value = @cur_token.literal
      )

      return AST::ErrorExpression.new(@cur_token, @errors.last) if !expect_peek(Token::ASSIGN)

      next_token

      value = parse_expression(Precedences::Lowest)

      if peek_token_is?(Token::SEMICOLON)
        next_token
      end

      return AST::ConstStatement.new(token, name, value)
    end

    def parse_return_statement
      token = @cur_token

      next_token

      return_value = parse_expression(Precedences::Lowest)

      if peek_token_is?(Token::SEMICOLON)
        next_token
      end

      return AST::ReturnStatement.new(token, return_value)
    end

    def parse_break_statement
      token = @cur_token

      if peek_token_is?(Token::SEMICOLON)
        next_token
      end

      return AST::BreakStatement.new(token)
    end

    def cur_token_is?(token : Token::Token)
      @cur_token.type == token.type
    end

    def peek_token_is?(token : Token::Token)
      @peek_token.type == token.type
    end

    def expect_peek(token : Token::Token)
      if peek_token_is?(token)
        next_token
        return true
      end
      peek_error(token)
      return false
    end

    def peek_error(token : Token::Token)
      @errors << {@peek_token, "Expected next token to be #{token.type}, got #{@peek_token.type} instead"}
    end

    def peek_precedence
      precedence = @precedences.has_key?(@peek_token.type)
      if precedence
        return @precedences[@peek_token.type]
      end
      return Precedences::Lowest
    end

    def cur_precedence
      precedence = @precedences.has_key?(@cur_token.type)
      if precedence
        return @precedences[@cur_token.type]
      end
      return Precedences::Lowest
    end

    def formatted_error(error : Tuple(Token::Token, ::String))
      error_token, error_text = error[0], error[1]

      pretty = "\nParse Error: #{error_text}".colorize(:red).to_s + "\n\n"

      lines = @lexer.input.as(String).lines
      line = "  #{error_token.line} | "
      error_line = error_token.line - 1

      pretty += "#{line.colorize(:dark_gray).to_s}#{lines[error_line]}\n"
      pretty += (" " * ((error_token.column - 1) + line.size)) + "^".colorize(:green).to_s

      pretty += "\n"

      return pretty
    end
  end
end
