require "debug"

require "../ast"
require "../object"

module Evaluator
  class Evaluator
    property program : AST::Program

    NULL  = PheltObject::Null.new
    TRUE  = PheltObject::Boolean.new(true)
    FALSE = PheltObject::Boolean.new(false)

    def initialize(@program)
    end

    def eval
      eval(@program)
    end

    def eval(node : AST::Node) : PheltObject::Object
      case node
      when AST::Program
        return eval_program(node.statements)
      when AST::ExpressionStatement
        return eval(node.expression)
      when AST::IntegerLiteral
        return PheltObject::Integer.new(node.value)
      when AST::FloatLiteral
        return PheltObject::Float.new(node.value)
      when AST::BooleanLiteral
        return bool_to_boolean(node.value)
      when AST::PrefixExpression
        right = eval(node.right)
        return eval_prefix_expression(node.operator, right)
      when AST::InfixExpression
        left = eval(node.left)
        right = eval(node.right)
        return eval_infix_expression(node.operator, left, right)
      when AST::BlockStatement
        return eval_block_statement(node)
      when AST::IfExpression
        return eval_if_expression(node)
      when AST::ReturnStatement
        value = eval(node.return_value)
        return PheltObject::Return.new(value)
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

      statements.each do |statement|
        result = eval(statement)
        if result.is_a? PheltObject::Return
          return result.value
        end
      end

      result
    end

    def eval_block_statement(block : AST::BlockStatement)
      result = NULL

      block.statements.each do |statement|
        result = eval(statement)

        if result.is_a?(PheltObject::Return)
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
      return NULL
    end

    def eval_infix_expression(operator : String, left : PheltObject::Object, right : PheltObject::Object)
      if (left.is_a?(PheltObject::Integer) || left.is_a?(PheltObject::Float)) && (right.is_a?(PheltObject::Integer) || right.is_a?(PheltObject::Float))
        return eval_number_infix_expression(operator, left, right)
      end

      if operator == "=="
        return bool_to_boolean(left == right)
      end

      if operator == "!="
        return bool_to_boolean(left != right)
      end

      return NULL
    end

    def eval_number_infix_expression(operator : String, left : PheltObject::Number, right : PheltObject::Number)
      if (left.is_a?(PheltObject::Integer) || left.is_a?(PheltObject::Float)) && (right.is_a?(PheltObject::Integer) || right.is_a?(PheltObject::Float))
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
          value = NULL
        end

        return PheltObject::Integer.new(value.to_i64) if value.is_a? Int
        return PheltObject::Float.new(value.to_f64) if value.is_a? Float
        return bool_to_boolean(value) if value.is_a? Bool
        return NULL
      end
      return NULL
    end

    def eval_boolean_infix_expression(operator : String, left : PheltObject::Number, right : PheltObject::Number)
      if (left.is_a?(PheltObject::Integer) || left.is_a?(PheltObject::Float)) && (right.is_a?(PheltObject::Integer) || right.is_a?(PheltObject::Float))
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
        else
          value = NULL
        end

        return PheltObject::Integer.new(value.to_i64) if value.is_a? Int
        return PheltObject::Float.new(value.to_f64) if value.is_a? Float
        return NULL
      end
      return NULL
    end
  end
end
