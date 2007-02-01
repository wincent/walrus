#!/usr/bin/env ruby
# Copyright 2007 Wincent Colaiuta
# $Id$

require 'test_helper'
require 'walrus/compiler'

module Walrus
  class CompilerTest < Test::Unit::TestCase
    
    def test_compiled_text_token_round_trip
#      @accumulator = ""
#      eval(Text.new("foobar").compiled_string)   # requires self.accumulate helper method
#      assert_equal "foobar", @accumulator
    end
    
  end # class CompilerTest
end # Walrus

