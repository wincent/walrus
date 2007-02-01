#!/usr/bin/env ruby
# Copyright 2007 Wincent Colaiuta
# $Id$

require 'test_helper'
require 'walrus/template'

module Walrus
  # Tests for Template class
  class TemplateTest < Test::Unit::TestCase

    def test_instantiate_template
      assert_not_nil Template.new
    end
  
    def test_fill_returns_empty_string_if_instantiated_without_string
      assert_equal "", Template.new.fill
    end
  
    def test_instantiate_with_nil
      assert_not_nil Template.new(nil)
    end
  
    def test_fill_returns_empty_string_if_instantiated_with_nil
      assert_equal "", Template.new(nil).fill
    end
  
    def test_instantiate_with_string
      template = Template.new("this is the template")
      assert_equal "this is the template", template.fill
    end
  
    def test_instantiate_with_pathname
      # TODO: test for instantiate with pathname
    end
  
    def test_instantiate_with_file
      # TODO: tests for instantiate with file
    end
  
    def test_comments_omitted_from_output
      template = Template.new("template text... ## this is a comment")
      assert_equal "template text... ", template.fill
    end
  
    def test_compile
      # don't really know how to test this
      # TODO: compile tests
    end
  
    def test_run
      # TODO: run tests
    end
  
  end # class TemplateTest
end # module Walrus

