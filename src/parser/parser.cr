require "debug"

require "../ast/*"
require "../lexer"
require "../token"

module Parser
  alias PrefixParser = -> AST::Expression
  alias InfixParser = (AST::Expression) -> AST::Expression

  enum Precedences
    Lowest      # none
    Equals      # ==
    LessGreater # > or <
    Sum         # +
    Product     # *
    Prefix      # -X or !X
    Call        # myFunction(X)
    Index       # array[index]
  end

  class Parser
    property errors : Array(String) = [] of String

    @cur_token : Token::Token = Token::ILLEGAL
    @peek_token : Token::Token = Token::ILLEGAL

    @prefix_parsers = {} of Token::Type => PrefixParser
    @infix_parsers = {} of Token::Type => InfixParser

    @precedences = {
      Token::EQ.type       => Precedences::Equals,
      Token::NOT_EQ.type   => Precedences::Equals,
      Token::LT.type       => Precedences::LessGreater,
      Token::GT.type       => Precedences::LessGreater,
      Token::PLUS.type     => Precedences::Sum,
      Token::MINUS.type    => Precedences::Sum,
      Token::SLASH.type    => Precedences::Product,
      Token::ASTERISK.type => Precedences::Product,
      Token::LPAREN.type   => Precedences::Call,
      Token::LBRACKET.type => Precedences::Index,
    } of Token::Type => Precedences

    def initialize(@lexer : Lexer::Lexer)
      register_parser_identifier
      register_parser_integer_literal
      register_parser_float_literal
      register_parser_boolean_literal
      register_parser_string_literal
      register_parser_prefix_expression
      register_parser_infix_expression
      register_parser_grouped_expression
      register_parser_if_expression
      register_parser_function_literal
      register_parser_do_literal
      register_parser_array_literal
      register_parser_array_index

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
        # debug!(statement)
        unless statement.nil?
          program.statements << statement
        end
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
        @errors << "no prefix parser for [#{@cur_token.type} #{@cur_token.literal}]"
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
          error = "could not parse #{@cur_token.literal} as an Int64"
          @errors << error
          return AST::ErrorExpression.new(token, error)
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
          error = "could not parse #{@cur_token.literal} as an Float64"
          @errors << error
          return AST::ErrorExpression.new(token, error)
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
      @infix_parsers[Token::EQ.type] = parser
      @infix_parsers[Token::NOT_EQ.type] = parser
      @infix_parsers[Token::LT.type] = parser
      @infix_parsers[Token::GT.type] = parser
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
        errors << "Unexpected argument type #{@cur_token.type}, expected IDENT"
      else
        identifiers << AST::Identifier.new(@cur_token, @cur_token.literal)
      end

      while peek_token_is?(Token::COMMA)
        next_token
        next_token

        if (@cur_token.type != Token::IDENT.type)
          errors << "Unexpected argument type #{@cur_token.type}, expected IDENT"
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
        unless statement.nil?
          block.statements << statement
        end
        next_token
      end

      block
    end

    def parse_let_statement
      token = @cur_token

      return nil if !expect_peek(Token::IDENT)

      name = AST::Identifier.new(
        token = @cur_token,
        value = @cur_token.literal
      )

      return nil if !expect_peek(Token::ASSIGN)

      next_token

      value = parse_expression(Precedences::Lowest)

      if peek_token_is?(Token::SEMICOLON)
        next_token
      end

      return AST::LetStatement.new(token, name, value)
    end

    def parse_const_statement
      token = @cur_token

      return nil if !expect_peek(Token::IDENT)

      name = AST::Identifier.new(
        token = @cur_token,
        value = @cur_token.literal
      )

      return nil if !expect_peek(Token::ASSIGN)

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
      @errors << "expected next token to be #{token.type}, got #{@peek_token.type} instead"
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
  end
end
