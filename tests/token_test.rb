# Copyright 2007 Wincent Colaiuta
# $Id$

require 'test_helper'
require 'walrus/token'

module Walrus
  class TokenTest < Test::Unit::TestCase
    
    def test_raise_if_initialized_with_nil_type
      assert_raise ArgumentError do
        Token.new(nil, 'foobar')
      end
    end
    
    def test_raise_if_initialized_with_nil_input_string
      assert_raise ArgumentError do
        Token.new(:text_token, nil)
      end
    end
    
    def test_raise_if_initialized_with_nil_type_and_input_string
      assert_raise ArgumentError do
        Token.new(nil, nil)
      end
    end
    
    def test_initialize_with_optional_line
      
      # no optional parameters
      token = Token.new(:eol_token, "\n")
      assert_nil token.line_number
      assert_nil token.column_number
      assert_nil token.filename
      
      # this time supply a line number
      token = Token.new(:eol_token, "\n", 10)
      assert_equal 10, token.line_number
      assert_nil token.column_number
      assert_nil token.filename
      
    end
    
    def test_initialize_with_optional_column
      
      # with line number
      token = Token.new(:eol_token, "\n", 10, 15)
      assert_equal 10,  token.line_number
      assert_equal 15, token.column_number
      assert_nil token.filename
      
      # without line number
      token = Token.new(:eol_token, "\n", nil, 15)
      assert_nil token.line_number
      assert_equal 15, token.column_number
      assert_nil token.filename
      
    end
    
    def test_initialize_with_optional_filename
      
      # with line number and column number
      token = Token.new(:eol_token, "\n", 10, 15, 'foobar')
      assert_equal 10, token.line_number
      assert_equal 15, token.column_number
      assert_equal 'foobar', token.filename
      
      # with only line number
      token = Token.new(:eol_token, "\n", 10, nil, 'foobar')
      assert_equal 10,  token.line_number
      assert_nil token.column_number
      assert_equal 'foobar', token.filename
      
      # with only column number
      token = Token.new(:eol_token, "\n", nil, 15, 'foobar')
      assert_nil token.line_number
      assert_equal 15, token.column_number
      assert_equal 'foobar', token.filename
      
    end
    
    def test_location
      token = Token.new(:text_token, 'text')
      assert_nil token.line_number
      assert_nil token.column_number
      token.location = [10, 15]
      assert_equal 10, token.line_number
      assert_equal 15, token.column_number
    end
    
    def test_type
      assert_equal :foo, Token.new(:foo, 'text').type
    end
    
    def test_text_string
      assert_equal 'text', Token.new(:foo, 'text').text_string
    end
    
    def test_to_s
      assert_equal 'text', Token.new(:foo, 'text').to_s
    end
    
    def test_value_for_key
      token = Token.new(:foo, 'text')
      assert_nil token.value_for_key(:key)
      token.set_value_for_key('value', :key)
      assert_equal 'value', token.value_for_key(:key)      
    end
    
    def test_dup
      token = Token.new(:foo, 'text', 1, 2, 'file...')
      token.set_value_for_key('hello', :greeting)
      copy = token.dup
      assert_equal token, copy
      assert_not_equal token.object_id, copy.object_id
      assert_equal token.type, copy.type
      assert_equal token.text_string, copy.text_string
      assert_not_equal token.text_string.object_id, copy.text_string.object_id
      assert_equal token.line_number, copy.line_number
      assert_equal token.column_number, copy.column_number
      assert_equal token.filename, copy.filename
      assert_equal token.value_for_key(:greeting), copy.value_for_key(:greeting)
      assert_not_equal token.value_for_key(:greeting).object_id, copy.value_for_key(:greeting).object_id
    end
    
    def test_clone
      token = Token.new(:foo, 'text', 1, 2, 'file...')
      token.set_value_for_key('hello', :greeting)
      copy = token.clone
      assert_equal token, copy
      assert_not_equal token.object_id, copy.object_id
      assert_equal token.type, copy.type
      assert_equal token.text_string, copy.text_string
      assert_not_equal token.text_string.object_id, copy.text_string.object_id
      assert_equal token.line_number, copy.line_number
      assert_equal token.column_number, copy.column_number
      assert_equal token.filename, copy.filename
      assert_equal token.value_for_key(:greeting), copy.value_for_key(:greeting)
      assert_not_equal token.value_for_key(:greeting).object_id, copy.value_for_key(:greeting).object_id
    end
    
  end # class TokenTest
end # walrus
