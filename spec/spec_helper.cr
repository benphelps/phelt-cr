require "spec"
require "../src/object"
require "../src/token"
require "../src/lexer"
require "../src/parser"
require "../src/ast"
require "../src/evaluator"

def test_statement(statement : AST::Statement)
  fail("Unhandled test_statement: #{statement.class}")
end

def test_statement(statement : AST::Statement, name)
  fail("Unhandled test_statement combination: #{statement.class}, #{name.class}")
end

def test_statement(statement : AST::ReturnStatement)
  statement.token_literal.should eq("return")
end

def test_statement(statement : AST::LetStatement, name : String)
  statement.token_literal.should eq(name)
  statement.name.value.should eq(name)
  statement.name.token_literal.should eq(name)
end

def test_statement(statement : AST::AssignmentInfixExpression, name : String)
  statement.token_literal.should eq(name)
  statement.identifier.value.should eq(name)
  statement.name.token_literal.should eq(name)
end

def test_statement(statement : AST::ConstStatement, name : String)
  statement.token_literal.should eq(name)
  statement.name.value.should eq(name)
  statement.name.token_literal.should eq(name)
end

def test_literal(literal, value)
  fail("Unhandled test_literal combination: #{literal.class}, #{value.class}")
end

def test_literal(literal : AST::Identifier, value : String)
  literal.value.should eq(value)
  literal.token_literal.should eq("#{value}")
end

def test_literal(literal : AST::IntegerLiteral, value : Int64)
  literal.value.should eq(value)
  literal.token_literal.should eq("#{value}")
end

def test_literal(literal : AST::FloatLiteral, value : Float64)
  literal.value.should eq(value)
  literal.token_literal.should eq("#{value}")
end

def test_literal(literal : AST::StringLiteral, value : String)
  literal.value.should eq(value)
  literal.token_literal.should eq("#{value}")
end

def test_literal(literal : AST::BooleanLiteral, value : Bool)
  literal.value.should eq(value)
  literal.token_literal.should eq("#{value}")
end

def test_infix(infix : AST::Expression, left, operator, right)
  fail("Unhandled test_infix combination: #{infix.class}, #{left.class}, #{operator.class}, #{right.class}")
end

def test_infix(infix : AST::InfixExpression, left, operator, right)
  test_literal(infix.left, left)
  infix.operator.should eq(operator)
  test_literal(infix.right, right)
end

def check_parser_errors(parser : Parser::Parser)
  if parser.errors.size === 0
    return
  end

  fail(parser.errors.join(", "))
end
