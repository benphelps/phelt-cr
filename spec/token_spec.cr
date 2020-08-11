require "./spec_helper"

private def it_lexes(input : String, type : Token::Token)
  it "lexes #{input.inspect}" do
    lexer = Lexer::Lexer.new input
    token = lexer.next_token
    token.type.should eq(type.type)
    token.literal.should eq(type.literal)
  end
end

private def it_lexes(input : String, type : Token::Token, literal : String)
  it "lexes #{input.inspect}" do
    lexer = Lexer::Lexer.new input
    token = lexer.next_token
    token.type.should eq(type.type)
    token.literal.should eq(literal)
  end
end

private def it_lexes_identifiers(identifiers)
  identifiers.each do |identifier|
    it_lexes identifier, Token::IDENT, identifier
  end
end

describe Lexer::Lexer do
  it_lexes "", Token::EOF
  it_lexes "let", Token::LET
  it_lexes "five", Token::IDENT, "five"
  it_lexes "=", Token::ASSIGN
  it_lexes "5", Token::INT, "5"
  it_lexes "5.5", Token::FLOAT, "5.5"
  it_lexes ";", Token::SEMICOLON
  it_lexes "if", Token::IF
  it_lexes "else", Token::ELSE
  it_lexes "fn", Token::FUNCTION
  it_lexes "return", Token::RETURN
  it_lexes "(", Token::LPAREN
  it_lexes ")", Token::RPAREN
  it_lexes "{", Token::LBRACE
  it_lexes "}", Token::RBRACE
  it_lexes "[", Token::LBRACKET
  it_lexes "]", Token::RBRACKET
  it_lexes "<", Token::LT
  it_lexes ">", Token::GT
  it_lexes "==", Token::EQ
  it_lexes "!=", Token::NOT_EQ
  it_lexes "!", Token::BANG
  it_lexes "-", Token::MINUS
  it_lexes "+", Token::PLUS
  it_lexes "*", Token::ASTERISK
  it_lexes "/", Token::SLASH
  it_lexes "\"foobar\"", Token::STRING, "foobar"
  it_lexes "\"foo bar\"", Token::STRING, "foo bar"
  it_lexes "do", Token::DO
  it_lexes "const", Token::CONST
end
