#!/usr/bin/env ruby
# Copyright 2007 Wincent Colaiuta
# $Id$

require 'test_helper'
require 'walrus/lexer_error'

module Walrus
  class LexerErrorTest < Test::Unit::TestCase
  
    def test_new
    
      # nil line number is fine
      error = nil
      assert_nothing_raised do
        error = LexerError.new(nil, "filename", nil, 0)
      end
      assert_not_nil error
      assert_equal "filename", error.filename
      assert_nil error.line_number
      assert_equal 0, error.column_number
    
      # nil column number is fine
      assert_nothing_raised do
        error = LexerError.new(nil, "filename", 0, nil)
      end
      assert_not_nil error
      assert_equal "filename", error.filename
      assert_equal 0, error.line_number
      assert_nil error.column_number
    
      # both line and column is fine
      assert_nothing_raised do
        error = LexerError.new(nil, "filename", nil, nil)
      end
      assert_not_nil error
      assert_equal "filename", error.filename
      assert_nil error.line_number
      assert_nil error.column_number
    
      # nil message, all other arguments non-nil
      error = nil
      assert_nothing_raised do
        error = LexerError.new(nil, "filename", 0, 0)
      end
      assert_not_nil error
      assert_equal "filename", error.filename
      assert_equal 0, error.line_number
      assert_equal 0, error.column_number
    
      # nil filename is ok
      assert_nothing_raised ArgumentError do
        error = LexerError.new(nil, nil, 0, 0)
      end
      assert_not_nil error
      assert_nil error.filename
      assert_equal 0, error.line_number
      assert_equal 0, error.column_number
    
      # try with some more interesting values
      error = LexerError.new(nil, "filename", 25, 60)
      assert_equal "filename", error.filename
      assert_equal 25, error.line_number
      assert_equal 60, error.column_number
    
    end
  
    def test_accessors
    
      error = LexerError.new(nil, "filename", 25, 60)
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
      error = LexerError.new(nil, "filename", 25, 60)
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
      error = LexerError.new(nil, "filename", 25, 60)
      assert_equal "Walrus::LexerError at filename:25:60", error.to_s
    
      # nil filename
      error.filename = nil
      assert_equal "Walrus::LexerError at 25:60", error.to_s
    
      # now with optional message included
      error = LexerError.new("fatal err", "filename", 25, 60)
      assert_equal "fatal err (Walrus::LexerError at filename:25:60)", error.to_s
    
      error.filename = nil
      assert_equal "fatal err (Walrus::LexerError at 25:60)", error.to_s
    
      # now with nil line number
      error.line_number = nil
      assert_equal "fatal err (Walrus::LexerError at ?:60)", error.to_s
    
      # and nil column number
      error.column_number = nil
      assert_equal "fatal err (Walrus::LexerError at ?:?)", error.to_s
    
    end  
  
  end
end
