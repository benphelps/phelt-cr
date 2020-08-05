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

private def test_object(object : PheltObject::Null)
  object.should be_a(PheltObject::Null)
end

describe "Evaluator" do
  it "TestEvalLiteralExpression" do
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

  it "TestEvalIfElseExpression" do
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

  it "TestReturnStatements" do
    tests = [
      {:input => "return 10;", :expected => 10_i64},
      {:input => "return 10; 9;", :expected => 10_i64},
      {:input => "return 5 + 5; 9;", :expected => 10_i64},
      {:input => "9; return 5 + 5; 9", :expected => 10_i64},
      {:input => "if (10 > 1) { if (10 > 1) { return 10; } return 1; }", :expected => 10_i64},
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
end
