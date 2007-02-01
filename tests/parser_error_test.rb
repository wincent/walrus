#!/usr/bin/env ruby
# Copyright 2007 Wincent Colaiuta
# $Id$

require 'test_helper'
require 'walrus/parser_error'
require 'walrus/token'

module Walrus
  class ParserErrorTest < Test::Unit::TestCase
    
    def test_accessors
    
      token = Token.new(:text, "Text...")
      token.filename  = "filename"
      token.location  = [25, 60]
    
      error = ParserError.new(nil, token)
      assert_equal "filename", error.filename
      assert_equal 25, error.line_number
      assert_equal 60, error.column_number
    
      error.filename = "new filename"
      assert_equal "new filename", error.filename
    
      error.line_number = 10
      assert_equal 10, error.line_number
    
      error.column_number = 96
      assert_equal 96, error.column_number
    
      error.line_number = nil
      assert_nil error.line_number
    
      error.column_number = nil
      assert_nil error.column_number
    
    end
  
    def test_location
    
      # non-nil filename
      token = Token.new(:text, "Text...")
      token.filename  = "filename"
      token.location  = [25, 60]
    
      error = ParserError.new(nil, token)
      assert_equal "filename:25:60", error.location
    
      # nil filename
      error.filename = nil
      assert_equal "25:60", error.location
    
      # nil line number
      error.line_number = nil
      assert_equal "?:60", error.location
    
      # nil column number
      error.column_number = nil
      assert_equal "?:?", error.location
    
    end
  
    def test_to_s
    
      # non-nil filename
      token = Token.new(:text, "Text...")
      token.filename  = "filename"
      token.location  = [25, 60]
      error = ParserError.new(nil, token)
      assert_equal "Walrus::ParserError at filename:25:60", error.to_s
    
      # nil filename
      error.filename = nil
      assert_equal "Walrus::ParserError at 25:60", error.to_s
    
      # now with optional message included
      error = ParserError.new("fatal err", token)
      assert_equal "fatal err (Walrus::ParserError at filename:25:60)", error.to_s
    
      error.filename = nil
      assert_equal "fatal err (Walrus::ParserError at 25:60)", error.to_s
    
      # now with nil line number
      error.line_number = nil
      assert_equal "fatal err (Walrus::ParserError at ?:60)", error.to_s
    
      # and nil column number
      error.column_number = nil
      assert_equal "fatal err (Walrus::ParserError at ?:?)", error.to_s
    
    end  
  
  end # class ParserErrorTest
end # module Walrus

