require "debug"

require "../ast"
require "../object/*"

module Evaluator
  class Evaluator
    property program : AST::Program
    property env : PheltObject::Environment

    @current_token : Token::Token = Token::EMPTY
    @current_block : Array(AST::Statement)

    NULL  = PheltObject::Null.new
    TRUE  = PheltObject::Boolean.new(true)
    FALSE = PheltObject::Boolean.new(false)

    def initialize(@program, @env = PheltObject::Environment.new)
      @current_block = @program.statements
    end

    def eval
      eval(@program)
    end

    def eval(node : AST::Node) : PheltObject::Object
      case node
      when AST::Program
        return eval_program(node.statements)
      when AST::ExpressionStatement
        @current_token = node.token
        return eval(node.expression)
      when AST::IntegerLiteral
        return PheltObject::Integer.new(node.value)
      when AST::FloatLiteral
        return PheltObject::Float.new(node.value)
      when AST::BooleanLiteral
        @current_token = node.token
        return bool_to_boolean(node.value)
      when AST::PrefixExpression
        @current_token = node.right.token
        right = eval(node.right)
        return right if error?(right)
        return eval_prefix_expression(node.operator, right)
      when AST::InfixExpression
        @current_token = node.left.token
        left = eval(node.left)
        return left if error?(left)
        @current_token = node.right.token
        right = eval(node.right)
        return right if error?(right)
        return eval_infix_expression(node.operator, left, right)
      when AST::BlockStatement
        return eval_block_statement(node)
      when AST::IfExpression
        @current_token = node.condition.token
        return eval_if_expression(node)
      when AST::ReturnStatement
        @current_token = node.token
        value = eval(node.return_value)
        return value if error?(value)
        return PheltObject::Return.new(value)
      when AST::LetStatement
        value = eval(node.value)
        return value if error?(value)
        @env.set(node.name.value, value)
        return PheltObject::Return.new(value)
      when AST::Identifier
        value = @env.get(node.value)
        error("Identifier not found: #{node.value}") if error?(value)
        return value
      else
        return NULL
      end
    end

    def eval(node : Nil)
      return NULL
    end

    def bool_to_boolean(value)
      value ? TRUE : FALSE
    end

    def truthy?(object : PheltObject::Object)
      case object
      when NULL
        return false
      when TRUE
        return true
      when FALSE
        return false
      else
        return true
      end
    end

    def eval_if_expression(expression : AST::IfExpression)
      condition = eval(expression.condition)
      return condition if error?(condition)
      if truthy?(condition)
        return eval(expression.consequence)
      elsif expression.alternative
        return eval(expression.alternative)
      else
        return NULL
      end
    end

    def eval_program(statements : Array(AST::Statement))
      result = NULL

      @current_block = statements

      statements.each do |statement|
        @current_token = statement.token
        result = eval(statement)
        if result.is_a? PheltObject::Return
          return result.value
        elsif result.is_a? PheltObject::Error
          return result
        end
      end

      result
    end

    def eval_block_statement(block : AST::BlockStatement)
      result = NULL

      @current_block = block.statements

      block.statements.each do |statement|
        @current_token = statement.token
        result = eval(statement)

        if result.is_a? PheltObject::Return | PheltObject::Error
          return result
        end
      end

      result
    end

    def eval_prefix_expression(operator : String, right : PheltObject::Object)
      case operator
      when "!"
        return eval_bang_operator_expression(right)
      when "-"
        return eval_minus_prefix_operator_expression(right)
      else
        return NULL
      end
    end

    def eval_bang_operator_expression(right : PheltObject::Object)
      case right
      when TRUE
        FALSE
      when FALSE
        TRUE
      when NULL
        TRUE
      else
        FALSE
      end
    end

    def eval_minus_prefix_operator_expression(right : PheltObject::Object)
      return PheltObject::Integer.new(-right.value) if right.is_a? PheltObject::Integer
      return PheltObject::Float.new(-right.value) if right.is_a? PheltObject::Float
      return error("Unkown operator -#{right.type}")
    end

    def eval_infix_expression(operator : String, left : PheltObject::Object, right : PheltObject::Object)
      if left.is_a?(PheltObject::Number) && right.is_a?(PheltObject::Number)
        return eval_number_infix_expression(operator, left, right)
      end

      if left.class != right.class
        return error("Expected #{left.type}, got #{right.type}")
      end

      if operator == "=="
        return bool_to_boolean(left == right)
      end

      if operator == "!="
        return bool_to_boolean(left != right)
      end

      return error("Unkown operator #{left.type} #{operator} #{right.type}")
    end

    def eval_number_infix_expression(operator : String, left : PheltObject::Number, right : PheltObject::Number)
      if left.is_a?(PheltObject::Number) && right.is_a?(PheltObject::Number)
        left_val = left.value
        right_val = right.value

        case operator
        when "+"
          value = left_val + right_val
        when "-"
          value = left_val - right_val
        when "*"
          value = left_val * right_val
        when "/"
          value = left_val / right_val
        when "<"
          value = left_val < right_val
        when ">"
          value = left_val > right_val
        when "=="
          value = left_val == right_val
        when "!="
          value = left_val != right_val
        else
          value = error("Unkown operator #{left.type} #{operator} #{right.type}")
        end

        return PheltObject::Integer.new(value.to_i64) if value.is_a? Int
        return PheltObject::Float.new(value.to_f64) if value.is_a? Float
        return bool_to_boolean(value) if value.is_a? Bool
      end
      return error("Unkown operator #{left.type} #{operator} #{right.type}")
    end

    def error?(value)
      return true if value.is_a? PheltObject::Error
      return false
    end

    def error(error : String)
      pretty = "\nEvaluation Error: #{error}".colorize(:red).to_s + "\n\n"

      lines = @program.orig.as(String).lines
      line = "  #{@current_token.line} | "
      error_line = @current_token.line - 1

      pretty += "#{line.colorize(:dark_gray).to_s}#{lines[error_line]}\n"
      pretty += (" " * ((@current_token.column - 1) + line.size)) + "^".colorize(:green).to_s

      pretty += "\n"

      PheltObject::Error.new(error, pretty, @current_token.line, @current_token.column)
    end
  end
end
