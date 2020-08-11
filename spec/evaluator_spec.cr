require "./spec_helper"

private def eval(input : String)
  lexer = Lexer::Lexer.new(input)
  parser = Parser::Parser.new(lexer)
  program = parser.parse_program
  evaluator = Evaluator::Evaluator.new(program)
  evaluator.eval
end

private def test_object(object : Evaluator::Evaluator, expected)
  fail("Evaluator::Evaluator failed to parse AST correctly.")
end

private def test_object(object : PheltObject::Object)
  fail("Unhandled test_statement: #{object.class}")
end

private def test_object(object : PheltObject::Object, expected)
  fail("Unhandled test_statement: #{object.class}, #{expected.class}")
end

private def test_object(object : PheltObject::Integer, expected)
  object.should be_a(PheltObject::Integer)
  object.value.should eq(expected)
end

private def test_object(object : PheltObject::Float, expected)
  object.should be_a(PheltObject::Float)
  object.value.should eq(expected)
end

private def test_object(object : PheltObject::Boolean, expected)
  object.should be_a(PheltObject::Boolean)
  object.value.should eq(expected)
end

private def test_object(object : PheltObject::String, expected)
  object.should be_a(PheltObject::String)
  object.value.should eq(expected)
end

private def test_object(object : PheltObject::Error, expected)
  object.should be_a(PheltObject::Error)
  object.message.should eq(expected)
end

private def test_object(object : PheltObject::Null, expected = nil)
  object.should be_a(PheltObject::Null)
end

describe "Evaluator" do
  it "should eval literal expressions" do
    tests = [
      {:input => "5", :expected => 5_i64},
      {:input => "10", :expected => 10_i64},
      {:input => "-5", :expected => -5_i64},
      {:input => "-10", :expected => -10_i64},
      {:input => "5.5", :expected => 5.5_f64},
      {:input => "10.5", :expected => 10.5_f64},
      {:input => "-5.5", :expected => -5.5_f64},
      {:input => "-10.5", :expected => -10.5_f64},
      {:input => "true", :expected => true},
      {:input => "false", :expected => false},
      {:input => "!true", :expected => false},
      {:input => "!false", :expected => true},
      {:input => "5+5", :expected => 10_i64},
      {:input => "10+10", :expected => 20_i64},
      {:input => "5.5+5.5", :expected => 11_i64},
      {:input => "10.5+10.5", :expected => 21_i64},
      {:input => "5.5+5", :expected => 10.5_f64},
      {:input => "10+10.5", :expected => 20.5_f64},
      {:input => "5 == 5", :expected => true},
      {:input => "5 != 5", :expected => false},
      {:input => "1 == 2", :expected => false},
      {:input => "2 != 1", :expected => true},
      {:input => "2 < 1", :expected => false},
      {:input => "2 > 1", :expected => true},
      {:input => "true == true", :expected => true},
      {:input => "false == false", :expected => true},
      {:input => "true != false", :expected => true},
      {:input => "false != false", :expected => false},
    ]

    tests.each do |test|
      evaluated = eval(test[:input].as(String))
      test_object(evaluated, test[:expected])
    end
  end

  it "should eval if expressions" do
    tests = [
      {:input => "if (true) { 10 }", :expected => 10_i64},
      {:input => "if (false) { 10 }", :expected => nil},
      {:input => "if (1) { 10 }", :expected => 10_i64},
      {:input => "if (1 < 2) { 10 }", :expected => 10_i64},
      {:input => "if (1 > 2) { 10 }", :expected => nil},
      {:input => "if (1 > 2) { 10 } else {  20 }", :expected => 20_i64},
      {:input => "if (1 < 2) { 10 } else { 20 }", :expected => 10_i64},
    ]

    tests.each do |test|
      evaluated = eval(test[:input].as(String))
      if test[:expected].is_a? Int64
        test_object(evaluated, test[:expected])
      else
        test_object(evaluated)
      end
    end
  end

  it "should eval return statements" do
    tests = [
      {:input => "return 10;", :expected => 10_i64},
      {:input => "return 10; 9;", :expected => 10_i64},
      {:input => "return 5 + 5; 9;", :expected => 10_i64},
      {:input => "9; return 5 + 5; 9", :expected => 10_i64},
      {:input => "if (5 > 2) { if (2 < 5) { return 10; } return 1; }", :expected => 10_i64},
    ]

    tests.each do |test|
      evaluated = eval(test[:input].as(String))
      if test[:expected].is_a? Int64
        test_object(evaluated, test[:expected])
      else
        test_object(evaluated)
      end
    end
  end

  it "should handle errors" do
    tests = [
      {:input => "if (5 > true) {\n  return true;\n}", :expected => "Expected number, got boolean"},
      {:input => "if (true > 5) {\n  return true;\n}", :expected => "Expected boolean, got number"},
      {:input => "if (5 > 1) {\n  return true + 5;\n}", :expected => "Expected boolean, got number"},
      {:input => "if (10 > 5) {\n  return -true;\n}", :expected => "Unkown operator -boolean"},
      {:input => "if (10 > 5) {\n  return true + false;\n}", :expected => "Unkown operator boolean + boolean"},
      {:input => "foobar;", :expected => "Undefined identifier foobar"},
    ]

    tests.each do |test|
      evaluated = eval(test[:input])
      evaluated.should be_a(PheltObject::Error)
      error = evaluated.as(PheltObject::Error)
      error.message.should eq(test[:expected])
    end
  end

  it "should evaluate let statements" do
    tests = [
      {input: "let foo = 5 + 5;", expected: 10},
    ]

    tests.each do |test|
      evaluated = eval(test[:input])
      test_object(evaluated, test[:expected])
    end
  end

  it "should evaluate string literals" do
    tests = [
      {input: "\"foo bar\"", expected: "foo bar"},
    ]

    tests.each do |test|
      evaluated = eval(test[:input])
      test_object(evaluated, test[:expected])
    end
  end

  it "should evaluate string concatenation" do
    tests = [
      {input: "\"foo\" + \"bar\"", expected: "foobar"},
    ]

    tests.each do |test|
      evaluated = eval(test[:input])
      test_object(evaluated, test[:expected])
    end
  end

  it "should evaluate function objects" do
    tests = [
      {input: "fn(x) { x + 2 }", expected: 10},
    ]

    tests.each do |test|
      evaluated = eval(test[:input])
      function = evaluated.as(PheltObject::Function)
      function.parameters.size.should eq(1)
      function.parameters[0].string.should eq("x")
      function.body.string.should eq("{ (x + 2) }")
    end
  end

  it "should evaluate function calls" do
    tests = [
      {input: "let add = fn(a, b) { a + b }; add(5, 5);", expected: 10},
      {input: "let add = fn(a, b) { a + b }; add(5 + 5, add(5, 5));", expected: 20},
      {input: "fn(a, b) { return a + b }(5, 5);", expected: 10},
    ]

    tests.each do |test|
      evaluated = eval(test[:input])
      test_object(evaluated, test[:expected])
    end
  end

  it "should evaluate builtin function calls" do
    tests = [
      {input: "len(\"\")", expected: 0},
      {input: "len(\"four\")", expected: 4},
      {input: "len(\"hello world\")", expected: 11},
      {input: "len([])", expected: 0},
      {input: "len([1,2,3,4,5])", expected: 5},
      {input: "first([])", expected: nil},
      {input: "first([1,2,3,4,5])", expected: 1},
      {input: "len(1)", expected: "Argument to len not supported, got number"},
      {input: "len(\"one\", \"two\");", expected: "Wrong number of arguments, got 2, expected 1"},
    ]

    tests.each do |test|
      evaluated = eval(test[:input])
      test_object(evaluated, test[:expected])
    end
  end

  it "should evaluate array literals" do
    input = "[1, 2 * 2, 3 + 3]"
    evaluated = eval(input)

    evaluated.should be_a(PheltObject::Array)
    array = evaluated.as(PheltObject::Array)

    array.elements.size.should eq(3)

    test_object(array.elements[0], 1)
    test_object(array.elements[1], 4)
    test_object(array.elements[2], 6)
  end

  it "should evaluate array index expressions" do
    tests = [
      {input: "[1, 2, 3][0]", expected: 1},
      {input: "[1, 2, 3][1]", expected: 2},
      {input: "[1, 2, 3][2]", expected: 3},
      {input: "let array = [1, 2, 3]; array[0];", expected: 1},
      {input: "let array = [1, 2, 3]; array[0] + array[1] + array[2];", expected: 6},
      {input: "let array = [1, 2, 3]; let i = array[0]; array[i];", expected: 2},
      {input: "[1, 2, 3][4]", expected: nil},
      {input: "[1, 2, 3][-1]", expected: nil},
    ]

    tests.each do |test|
      evaluated = eval(test[:input])
      test_object(evaluated, test[:expected])
    end
  end
end
