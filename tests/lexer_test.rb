#!/usr/bin/env ruby
# Copyright 2007 Wincent Colaiuta
# $Id$

require 'test_helper'
require 'walrus/lexer'
require 'walrus/lexer_error'
require 'walrus/line_scanner'
require 'walrus/token'

module Walrus
  # Tests for Lexer class
  class LexerTest < Test::Unit::TestCase
  
    def test_lexer_raises_on_nil_input
      assert_nothing_thrown do
        Lexer.new("")
      end
      assert_raise ArgumentError do
        Lexer.new(nil)
      end
    end
  
    def test_lex_with_empty_input
      lexer = Lexer.new("")
      assert_equal 0, lexer.tokens.length
    end
  
    def test_lex_with_single_line
      lexer = Lexer.new("foobar")
      assert_equal 1, lexer.tokens.length
      assert_kind_of Token, lexer.tokens[0]
      assert_equal :text, lexer.tokens[0].type
      assert_equal "foobar", lexer.tokens[0].to_s
    end
  
    def test_lex_with_two_lines
      lexer = Lexer.new("foo\nbar")
      assert_equal 3, lexer.tokens.length
      assert_kind_of Token, lexer.tokens[0]
      assert_equal :text, lexer.tokens[0].type
      assert_equal "foo", lexer.tokens[0].to_s
      assert_kind_of Token, lexer.tokens[1]
      assert_equal :eol, lexer.tokens[1].type
      assert_equal "\n", lexer.tokens[1].to_s
      assert_kind_of Token, lexer.tokens[2]
      assert_equal :text, lexer.tokens[2].type
      assert_equal "bar", lexer.tokens[2].to_s
    end
  
    def test_lex_with_trailing_newline
      lexer = Lexer.new("foobar\n")
      assert_equal 2, lexer.tokens.length
      assert_kind_of Token, lexer.tokens[0]
      assert_equal :text, lexer.tokens[0].type
      assert_equal "foobar", lexer.tokens[0].to_s
      assert_kind_of Token, lexer.tokens[1]
      assert_equal :eol, lexer.tokens[1].type
      assert_equal "\n", lexer.tokens[1].to_s
    end
  
  end # class LexerTest
end # module Walrus