require "./spec_helper"

describe "Parser" do
  it "should parse let statements" do
    tests = [
      {:input => "let x = 5;", :identifier => "x", :value => 5_i64},
      {:input => "let y = true;", :identifier => "y", :value => true},
      {:input => "let foobar = y;", :identifier => "foobar", :value => "y"},
    ]

    tests.each do |test|
      lexer = Lexer::Lexer.new(test[:input].as(String))
      parser = Parser::Parser.new(lexer)
      program = parser.parse_program
      check_parser_errors(parser)

      program.should_not be_nil
      program.statements.size.should eq(1)
      statement = program.statements[0].as(AST::LetStatement)

      test_statement(statement, test[:identifier])
      test_literal(statement.value, test[:value])
    end
  end

  it "should parse let statements" do
    tests = [
      {:input => "const x = 5;", :identifier => "x", :value => 5_i64},
      {:input => "const y = true;", :identifier => "y", :value => true},
      {:input => "const foobar = y;", :identifier => "foobar", :value => "y"},
    ]

    tests.each do |test|
      lexer = Lexer::Lexer.new(test[:input].as(String))
      parser = Parser::Parser.new(lexer)
      program = parser.parse_program
      check_parser_errors(parser)

      program.should_not be_nil
      program.statements.size.should eq(1)
      statement = program.statements[0].as(AST::ConstStatement)

      test_statement(statement, test[:identifier])
      test_literal(statement.value, test[:value])
    end
  end

  it "should parse return statements" do
    tests = [
      {:input => "return 5;", :value => 5_i64},
      {:input => "return true;", :value => true},
      {:input => "return foobar;", :value => "foobar"},
    ]

    tests.each do |test|
      lexer = Lexer::Lexer.new(test[:input].as(String))
      parser = Parser::Parser.new(lexer)
      program = parser.parse_program
      check_parser_errors(parser)

      program.should_not be_nil
      program.statements.size.should eq(1)
      statement = program.statements[0].as(AST::ReturnStatement)

      test_statement(statement)
      test_literal(statement.return_value, test[:value])
    end
  end

  it "string should match the expected expression" do
    program : AST::Program = AST::Program.new(
      statements = [
        AST::LetStatement.new(
          token = Token::Token.new("LET", "let"),
          name = AST::Identifier.new(
            token = Token::Token.new("IDENT", "myVar"),
            value = "myVar"
          ),
          value = AST::Identifier.new(
            token = Token::Token.new("IDENT", "anotherVar"),
            value = "anotherVar"
          )
        ),
      ] of AST::Statement
    )

    program.string.should eq("let myVar = anotherVar;")
  end

  it "should parse identifiers" do
    input = "foobar;"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)
    expression = statement.expression.as(AST::Identifier)

    statement.should be_a(AST::ExpressionStatement)
    expression.should be_a(AST::Identifier)
    expression.value.should eq("foobar")
    expression.token_literal.should eq("foobar")
  end

  it "should parse integer literals" do
    input = "5;"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)
    literal = statement.expression.as(AST::IntegerLiteral)

    statement.should be_a(AST::ExpressionStatement)
    test_literal(literal, 5_i64)
  end

  it "should parse boolean literals" do
    input = "true;"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)
    literal = statement.expression.as(AST::BooleanLiteral)

    statement.should be_a(AST::ExpressionStatement)
    test_literal(literal, true)
  end

  it "should parse string literals" do
    input = "\"foobar\";"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)
    literal = statement.expression.as(AST::StringLiteral)

    statement.should be_a(AST::ExpressionStatement)
    test_literal(literal, "foobar")
  end

  it "should parse prefix expressions" do
    tests = [
      {:input => "!5;", :operator => "!", :value => 5_i64},
      {:input => "!5.5;", :operator => "!", :value => 5.5},
      {:input => "-15;", :operator => "-", :value => 15_i64},
      {:input => "-15.5;", :operator => "-", :value => 15.5},
      {:input => "!true;", :operator => "!", :value => true},
      {:input => "!false;", :operator => "!", :value => false},
    ]

    tests.each do |test|
      lexer = Lexer::Lexer.new(test[:input].as(String))
      parser = Parser::Parser.new(lexer)
      program = parser.parse_program
      check_parser_errors(parser)

      program.should_not be_nil
      program.statements.size.should eq(1)

      statement = program.statements[0].as(AST::ExpressionStatement)
      expression = statement.expression.as(AST::PrefixExpression)

      statement.should be_a(AST::ExpressionStatement)
      expression.should be_a(AST::PrefixExpression)
      expression.operator.should eq(test[:operator])
      test_literal(expression.right, test[:value])
    end
  end

  it "should parse infix expressions" do
    tests = [
      {:input => "5 + 5;", :left => 5_i64, :operator => "+", :right => 5_i64},
      {:input => "5 - 5;", :left => 5_i64, :operator => "-", :right => 5_i64},
      {:input => "5 * 5;", :left => 5_i64, :operator => "*", :right => 5_i64},
      {:input => "5 / 5;", :left => 5_i64, :operator => "/", :right => 5_i64},
      {:input => "5 > 5;", :left => 5_i64, :operator => ">", :right => 5_i64},
      {:input => "5 < 5;", :left => 5_i64, :operator => "<", :right => 5_i64},
      {:input => "5 == 5;", :left => 5_i64, :operator => "==", :right => 5_i64},
      {:input => "5 != 5;", :left => 5_i64, :operator => "!=", :right => 5_i64},
      {:input => "5.5 + 5.5;", :left => 5.5, :operator => "+", :right => 5.5},
      {:input => "5.5 - 5.5;", :left => 5.5, :operator => "-", :right => 5.5},
      {:input => "5.5 * 5.5;", :left => 5.5, :operator => "*", :right => 5.5},
      {:input => "5.5 / 5.5;", :left => 5.5, :operator => "/", :right => 5.5},
      {:input => "5.5 > 5.5;", :left => 5.5, :operator => ">", :right => 5.5},
      {:input => "5.5 < 5.5;", :left => 5.5, :operator => "<", :right => 5.5},
      {:input => "5.5 == 5.5;", :left => 5.5, :operator => "==", :right => 5.5},
      {:input => "5.5 != 5.5;", :left => 5.5, :operator => "!=", :right => 5.5},
      {:input => "true == true;", :left => true, :operator => "==", :right => true},
      {:input => "true != false;", :left => true, :operator => "!=", :right => false},
      {:input => "false == false;", :left => false, :operator => "==", :right => false},
    ]

    tests.each do |test|
      lexer = Lexer::Lexer.new(test[:input].as(String))
      parser = Parser::Parser.new(lexer)
      program = parser.parse_program
      check_parser_errors(parser)

      program.should_not be_nil
      program.statements.size.should eq(1)

      statement = program.statements[0].as(AST::ExpressionStatement)
      expression = statement.expression.as(AST::InfixExpression)

      statement.should be_a(AST::ExpressionStatement)
      expression.should be_a(AST::InfixExpression)

      test_literal(expression.left, test[:left])
      expression.operator.should eq(test[:operator])
      test_literal(expression.right, test[:right])
    end
  end

  it "should handle operator precedence" do
    tests = [
      {:input => "-a * b", :output => "((-a) * b)"},
      {:input => "!-a", :output => "(!(-a))"},
      {:input => "a + b + c", :output => "((a + b) + c)"},
      {:input => "a + b - c", :output => "((a + b) - c)"},
      {:input => "a * b * c", :output => "((a * b) * c)"},
      {:input => "a * b / c", :output => "((a * b) / c)"},
      {:input => "a + b / c", :output => "(a + (b / c))"},
      {:input => "a + b * c + d / e - f", :output => "(((a + (b * c)) + (d / e)) - f)"},
      {:input => "3 + 4; -5 * 5", :output => "(3 + 4)((-5) * 5)"},
      {:input => "5 > 4 == 3 < 4", :output => "((5 > 4) == (3 < 4))"},
      {:input => "5 < 4 != 3 > 4", :output => "((5 < 4) != (3 > 4))"},
      {:input => "3 + 4 * 5 == 3 * 1 + 4 * 5", :output => "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"},
      {:input => "true", :output => "true"},
      {:input => "false", :output => "false"},
      {:input => "3 > 5 == false", :output => "((3 > 5) == false)"},
      {:input => "3 < 5 == true", :output => "((3 < 5) == true)"},
      {:input => "1 + (2 + 3) + 4", :output => "((1 + (2 + 3)) + 4)"},
      {:input => "(5 + 5) * 2", :output => "((5 + 5) * 2)"},
      {:input => "2 / (5 + 5)", :output => "(2 / (5 + 5))"},
      {:input => "-(5 + 5)", :output => "(-(5 + 5))"},
      {:input => "-(5.5 + 5.5)", :output => "(-(5.5 + 5.5))"},
      {:input => "!(true == true)", :output => "(!(true == true))"},
      {:input => "a + add(b * c) + d", :output => "((a + add((b * c))) + d)"},
      {:input => "add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", :output => "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"},
      {:input => "add(a + b + c * d / f + g)", :output => "add((((a + b) + ((c * d) / f)) + g))"},
      {:input => "a * [1, 2, 3, 4][b * c] * d", :output => "((a * ([1, 2, 3, 4][(b * c)])) * d)"},
      {:input => "add(a * b[2], b[1], 2 * [1, 2][1])", :output => "add((a * (b[2])), (b[1]), (2 * ([1, 2][1])))"},
    ] of Hash(Symbol, String)

    tests.each do |test|
      lexer = Lexer::Lexer.new(test[:input])
      parser = Parser::Parser.new(lexer)
      program = parser.parse_program
      check_parser_errors(parser)
      program.string.should eq(test[:output])
    end
  end

  it "should parse if expressions" do
    input = "if (x < y) { x }"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.should_not be_nil
    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)
    expression = statement.expression.as(AST::IfExpression)
    condition = expression.condition.as(AST::InfixExpression)

    test_literal(condition.left, "x")
    condition.operator.should eq("<")
    test_literal(condition.right, "y")

    consequence = expression.consequence.as(AST::BlockStatement)
    consequence.statements.size.should eq(1)

    consequence_stmt = consequence.statements[0].as(AST::ExpressionStatement)
    consequence_exp = consequence_stmt.expression.as(AST::Identifier)

    consequence_exp.value.should eq("x")
    consequence_exp.token_literal.should eq("x")
  end

  it "should parse else expressions" do
    input = "if (x < y) { x; } else { y; }"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.should_not be_nil
    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)
    expression = statement.expression.as(AST::IfExpression)
    condition = expression.condition.as(AST::InfixExpression)

    test_literal(condition.left, "x")
    condition.operator.should eq("<")
    test_literal(condition.right, "y")

    consequence = expression.consequence.as(AST::BlockStatement)
    consequence.statements.size.should eq(1)

    consequence_stmt = consequence.statements[0].as(AST::ExpressionStatement)
    consequence_exp = consequence_stmt.expression.as(AST::Identifier)

    consequence_exp.value.should eq("x")
    consequence_exp.token_literal.should eq("x")

    alternative = expression.alternative
    unless alternative.nil?
      alternative = expression.alternative.as(AST::BlockStatement)
      alternative.statements.size.should eq(1)

      alternative_stmt = alternative.statements[0].as(AST::ExpressionStatement)
      alternative_exp = alternative_stmt.expression.as(AST::Identifier)

      alternative_exp.value.should eq("y")
      alternative_exp.token_literal.should eq("y")
    end
  end

  it "should parse function expressions" do
    input = "fn(x, y) { x + y; }"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.should_not be_nil
    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)

    function = statement.expression.as(AST::FunctionLiteral)
    function.parameters.size.should eq(2)

    test_literal(function.parameters[0], "x")
    test_literal(function.parameters[1], "y")

    function.body.statements.size.should eq(1)
    body_stmt = function.body.statements[0].as(AST::ExpressionStatement)

    infix = body_stmt.expression.as(AST::InfixExpression)

    test_literal(infix.left, "x")
    infix.operator.should eq("+")
    test_literal(infix.right, "y")
  end

  it "should parse do expressions" do
    input = "do { x + y; }"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.should_not be_nil
    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)

    do_obj = statement.expression.as(AST::DoLiteral)

    do_obj.body.statements.size.should eq(1)
    body_stmt = do_obj.body.statements[0].as(AST::ExpressionStatement)

    infix = body_stmt.expression.as(AST::InfixExpression)

    test_literal(infix.left, "x")
    infix.operator.should eq("+")
    test_literal(infix.right, "y")
  end

  it "should parse function expressions" do
    input = "fn(x, y) { x + y; }"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.should_not be_nil
    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)

    function = statement.expression.as(AST::FunctionLiteral)
    function.parameters.size.should eq(2)

    test_literal(function.parameters[0], "x")
    test_literal(function.parameters[1], "y")

    function.body.statements.size.should eq(1)
    body_stmt = function.body.statements[0].as(AST::ExpressionStatement)

    infix = body_stmt.expression.as(AST::InfixExpression)

    test_literal(infix.left, "x")
    infix.operator.should eq("+")
    test_literal(infix.right, "y")
  end

  it "TestCallExpressionParsing" do
    input = "add(1, 2.3 * 3.4, 4 + 5);"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.should_not be_nil
    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)
    expression = statement.expression.as(AST::CallExpression)
    function = expression.function.should be_a(AST::Identifier)

    function.value.should eq("add")
    function.token_literal.should eq("add")

    expression.arguments.size.should eq(3)

    test_literal(expression.arguments[0], 1_i64)
    test_infix(expression.arguments[1], 2.3, "*", 3.4)
    test_infix(expression.arguments[2], 4_i64, "+", 5_i64)
  end

  it "should handle array literals" do
    input = "[1, 2 * 3, 3 + 3]"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.should_not be_nil
    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)
    array = statement.expression.as(AST::ArrayLiteral)

    statement.should be_a(AST::ExpressionStatement)
    array.should be_a(AST::ArrayLiteral)

    array.elements.size.should eq(3)

    test_literal(array.elements[0], 1_i64)
    test_infix(array.elements[1], 2_i64, "*", 3_i64)
    test_infix(array.elements[2], 3_i64, "+", 3_i64)
  end

  it "should handle array index expressions" do
    input = "foo[1 + 1]"

    lexer = Lexer::Lexer.new(input)
    parser = Parser::Parser.new(lexer)
    program = parser.parse_program
    check_parser_errors(parser)

    program.should_not be_nil
    program.statements.size.should eq(1)

    statement = program.statements[0].as(AST::ExpressionStatement)
    index = statement.expression.as(AST::IndexExpression)

    statement.should be_a(AST::ExpressionStatement)
    index.should be_a(AST::IndexExpression)

    test_literal(index.left, "foo")
    test_infix(index.index, 1_i64, "+", 1_i64)
  end
end
