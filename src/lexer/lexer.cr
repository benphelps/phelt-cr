require "../token"

module Lexer
  class Lexer
    getter input
    @position : Int32
    @read_position : Int32
    @char : Char
    @line : Int32 = 1
    @column : Int32 = 0
    @token_line : Int32 = 1
    @token_column : Int32 = 0

    def initialize(@input : String)
      @position = 0
      @read_position = 0
      @char = Char::ZERO
      read_char()
    end

    def read_char
      if @read_position >= @input.size
        @char = Char::ZERO
      else
        @char = @input[@read_position]
      end

      if @char == '\n'
        @line += 1
        @column = 1
      elsif @char != Char::ZERO
        @column += 1
      end

      @position = @read_position
      @read_position += 1
    end

    def peek_char
      if @read_position >= @input.size
        return Char::ZERO
      else
        return @input[@read_position]
      end
    end

    def next_token : Token::Token
      token : Token::Token

      skip_whitespace()

      @token_line = @line
      @token_column = @column

      case @char
      when '=' # Operators
        if peek_char() == '='
          token = new_multi_token(Token::EQ)
        else
          token = new_token(Token::ASSIGN)
        end
      when '+'
        if peek_char() == '='
          token = new_multi_token(Token::PLUS_ASSIGN)
        elsif peek_char() == '+'
          token = new_multi_token(Token::INCREMENT)
        else
          token = new_token(Token::PLUS)
        end
      when '-'
        if peek_char() == '='
          token = new_multi_token(Token::MINUS_ASSIGN)
        elsif peek_char() == '-'
          token = new_multi_token(Token::DECREMENT)
        else
          token = new_token(Token::MINUS)
        end
      when '!'
        if peek_char() == '='
          token = new_multi_token(Token::NOT_EQ)
        else
          token = new_token(Token::BANG)
        end
      when '/'
        if peek_char() == '='
          token = new_multi_token(Token::SLASH_ASSIGN)
        else
          token = new_token(Token::SLASH)
        end
      when '*'
        if peek_char() == '='
          token = new_multi_token(Token::ASTERISK_ASSIGN)
        else
          token = new_token(Token::ASTERISK)
        end
      when '%'
        token = new_token(Token::MODULUS)
      when '<'
        if peek_char() == '='
          token = new_multi_token(Token::LT_EQ)
        else
          token = new_token(Token::LT)
        end
      when '>'
        if peek_char() == '='
          token = new_multi_token(Token::GT_EQ)
        else
          token = new_token(Token::GT)
        end
      when ';' # Delimiters
        token = new_token(Token::SEMICOLON)
      when ':'
        token = new_token(Token::COLON)
      when '.'
        token = new_token(Token::PERIOD)
      when ','
        token = new_token(Token::COMMA)
      when '('
        token = new_token(Token::LPAREN)
      when ')'
        token = new_token(Token::RPAREN)
      when '{'
        token = new_token(Token::LBRACE)
      when '}'
        token = new_token(Token::RBRACE)
      when '['
        token = new_token(Token::LBRACKET)
      when ']'
        token = new_token(Token::RBRACKET)
      when '"'
        literal = read_string()
        token = new_token(Token::STRING, literal)
      when Char::ZERO
        token = new_token(Token::EOF, Char::ZERO)
      else # Identifiers
        if ::Lexer.is_letter?(@char)
          literal = read_identifier()
          token = new_token(Token.lookup_ident(literal), literal)
          return token
        elsif ::Lexer.is_number?(@char)
          literal = read_number()
          if literal =~ /\d+\.\d+/
            token = new_token(Token::FLOAT, literal)
            return token
          end
          token = new_token(Token::INT, literal)
          return token
        end
        token = new_token(Token::ILLEGAL)
      end

      if token.type != Token::EOF.type
        read_char()
      end

      token
    end

    def read_identifier
      position = @position
      while ::Lexer.is_letter?(@char)
        read_char()
      end
      @input[position..@position - 1]
    end

    def read_number
      have_decimal = false
      position = @position
      while ::Lexer.is_number?(@char) || (have_decimal == false && @char == '.' && ::Lexer.is_number?(peek_char()))
        have_decimal = true if @char == '.'
        read_char()
      end
      @input[position..@position - 1]
    end

    def read_string
      position = @position + 1
      loop do
        read_char()
        if @char == '"' || @char == Char::ZERO
          break
        end
      end
      @input[position..@position - 1]
    end

    def skip_whitespace
      while @char.whitespace?
        read_char()
      end
    end

    def new_multi_token(token : Token::Token)
      char = @char
      read_char()
      literal = char.to_s + @char.to_s
      new_token(token, literal)
    end

    def new_token(token : Token::Token)
      Token::Token.new(token.type, @char.to_s, @token_line, @token_column)
    end

    def new_token(token : Token::Token, literal : String | Char)
      Token::Token.new(token.type, literal.to_s, @token_line, @token_column)
    end
  end

  def self.is_letter?(char)
    char.ascii_letter? || char == '_'
  end

  def self.is_number?(char)
    char.ascii_number?
  end
end
