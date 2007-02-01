#!/usr/bin/env ruby
# Copyright 2007 Wincent Colaiuta
# $Id$

require 'test_helper'

# Require (and run) anything named "*_test.rb" in "tests" and its subdirectories
Dir[File.join(File.dirname(__FILE__), '**/*_test.rb')].each { |test| require test }
