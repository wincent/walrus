# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe Walrus::Grammar::DoubleQuotedStringLiteral do
  context 'compiling' do
    it 'should produce a string literal' do
      string = Walrat::StringResult.new('hello world')
      string.source_text = '"hello world"'
      compiled = Walrus::Grammar::DoubleQuotedStringLiteral.new(string).compile
      compiled.should == '"hello world"'
      eval(compiled).should == 'hello world'
    end
  end
end

describe Walrus::Grammar::SingleQuotedStringLiteral do
  context 'compiling' do
    it 'should produce a string literal' do
      string = Walrat::StringResult.new('hello world')
      string.source_text = "'hello world'"
      compiled = Walrus::Grammar::SingleQuotedStringLiteral.new(string).compile
      compiled.should == "'hello world'"
      eval(compiled).should == 'hello world'
    end
  end
end
