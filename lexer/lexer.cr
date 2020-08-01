require "../token"

module Lexer
  class Lexer
    @position : Int32
    @read_position : Int32
    @char : Char

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

      case @char
      when '=' # Operators
        if peek_char() == '='
          char = @char
          read_char()
          literal = char.to_s + @char.to_s
          token = new_token(Token::EQ, literal)
        else
          token = new_token(Token::ASSIGN, @char)
        end
      when '+'
        token = new_token(Token::PLUS, @char)
      when '-'
        token = new_token(Token::MINUS, @char)
      when '!'
        if peek_char() == '='
          char = @char
          read_char()
          literal = char.to_s + @char.to_s
          token = new_token(Token::NOT_EQ, literal)
        else
          token = new_token(Token::BANG, @char)
        end
      when '/'
        token = new_token(Token::SLASH, @char)
      when '*'
        token = new_token(Token::ASTERISK, @char)
      when '<'
        token = new_token(Token::LT, @char)
      when '>'
        token = new_token(Token::GT, @char)
      when ';' # Delimiters
        token = new_token(Token::SEMICOLON, @char)
      when ','
        token = new_token(Token::COMMA, @char)
      when '('
        token = new_token(Token::LPAREN, @char)
      when ')'
        token = new_token(Token::RPAREN, @char)
      when '{'
        token = new_token(Token::LBRACE, @char)
      when '}'
        token = new_token(Token::RBRACE, @char)
      when Char::ZERO
        token = new_token(Token::EOF, Char::ZERO)
      else # Identifiers
        if ::Lexer.is_letter?(@char)
          literal = read_identifier()
          token = new_token(Token.lookup_ident(literal), literal)
          return token
        elsif ::Lexer.is_number?(@char)
          literal = read_number()
          token = new_token(Token::INT, literal)
          return token
        end
        token = new_token(Token::ILLEGAL, @char)
      end

      read_char
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
      position = @position
      while ::Lexer.is_number?(@char)
        read_char()
      end
      @input[position..@position - 1]
    end

    def skip_whitespace
      while @char.whitespace?
        read_char()
      end
    end

    def new_token(token : Token::Token, literal : String | Char)
      Token::Token.new(token.type, literal.to_s)
    end
  end

  def self.is_letter?(char)
    char.ascii_letter? || char == '_'
  end

  def self.is_number?(char)
    char.ascii_number?
  end
end
