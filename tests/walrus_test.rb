#!/usr/bin/env ruby
# Copyright 2007 Wincent Colaiuta
# $Id$

require 'test_helper'
require 'walrus'

# Tests for Walrus module
class WalrusCamelCaseTest < Test::Unit::TestCase
  
  def setup
    self.extend(Walrus::CamelCase)
  end
  
  def test_require_name_from_classname_bad_input
    
    # nil is bad
    assert_raise ArgumentError do
      self.require_name_from_classname(nil)
    end
    
    # empty strings are bad
    assert_raise ArgumentError do
      self.require_name_from_classname("")
    end

    # must start with uppercase, not lowercase    
    assert_raise ArgumentError do
      self.require_name_from_classname("theClass")
    end

    # must not start with numbers    
    assert_raise ArgumentError do
      self.require_name_from_classname("99X")
    end

    # must not start with underscores
    assert_raise ArgumentError do      
      self.require_name_from_classname("_Foo")
    end
    
    # leading and trailing whitespace is a bad
    assert_raise ArgumentError do
      self.require_name_from_classname("Foo ")
    end
    assert_raise ArgumentError do
      self.require_name_from_classname(" Foo")
    end
    assert_raise ArgumentError do
      self.require_name_from_classname(" Foo ")
    end
    
  end
  
  def test_require_name_from_classname_good_input
  
    # single letters are ok
    assert_equal "a", self.require_name_from_classname("A")
    
    # runs of capitals are ok
    assert_equal "eol_token", self.require_name_from_classname("EOLToken")
    
    # consecutive underscores are ok
    assert_equal "eol__token", self.require_name_from_classname("EOL__Token")
    assert_equal "eol__token", self.require_name_from_classname("EOL__token")
    assert_equal "eol__token", self.require_name_from_classname("Eol__Token")
    assert_equal "eol__token", self.require_name_from_classname("Eol__token")
    
    # trailing underscores are ok as well
    assert_equal "eol__", self.require_name_from_classname("EOL__")
    assert_equal "eol__", self.require_name_from_classname("Eol__")
    
    # misc tests
    assert_equal "foo", self.require_name_from_classname("Foo")
    assert_equal "my_url_handler", self.require_name_from_classname("MyURLHandler")
    assert_equal "signals_37", self.require_name_from_classname("Signals37")
    assert_equal "my_class", self.require_name_from_classname("MyClass")
    assert_equal "foo_bar", self.require_name_from_classname("Foo_bar")
    
  end
  
  def test_require_name_from_classname_regressions
  
    # these were cases which didn't work while first developing the method
    assert_equal "c_99_case", self.require_name_from_classname("C99case")
    assert_equal "eol_99_do_fun", self.require_name_from_classname("EOL99doFun")
    assert_equal "foo_bar", self.require_name_from_classname("Foo_Bar")
    
  end
    
  def test_classname_from_require_name_bad_input
    
    # nil is bad
    assert_raises ArgumentError do
      self.classname_from_require_name(nil)
    end
    
    # empty strings are bad
    assert_raises ArgumentError do
      self.classname_from_require_name("")
    end
    
    # must start with a letter
    assert_raises ArgumentError do
      self.classname_from_require_name("9")
    end
    assert_raises ArgumentError do
      self.classname_from_require_name("9foo")
    end
    assert_raises ArgumentError do
      self.classname_from_require_name("_nothing")
    end
    
    # uppercase is bad
    assert_raises ArgumentError do
      self.classname_from_require_name("Foo")
    end
    assert_raises ArgumentError do
      self.classname_from_require_name("FOO")
    end
    
    # trailing and leading whitespace is bad
    assert_raises ArgumentError do
      self.classname_from_require_name(" foo")
    end
    assert_raises ArgumentError do
      self.classname_from_require_name("foo ")
    end
    assert_raises ArgumentError do
      self.classname_from_require_name(" foo ")
    end
    
  end
  
  def test_classname_from_require_name_good_input
    
    assert_equal "FooBar", self.classname_from_require_name("foo_bar")
    assert_equal "F", self.classname_from_require_name("f")
    assert_equal "FooBar", self.classname_from_require_name("foo__bar")
    assert_equal "Foo", self.classname_from_require_name("foo__")
    assert_equal "EolToken", self.classname_from_require_name("eol_token")
    
  end
  
end