# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe Walrus::Grammar::Placeholder do
  describe 'a placeholder with no parameters' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be substituted into the output' do
      Object.class_eval @parser.compile "#set $foo = 'bar'\n$foo",
        :class_name => :PlaceholderSpecAlpha
      expect(Walrus::Grammar::PlaceholderSpecAlpha.new.fill).to eq('bar')
    end
  end

  describe 'a placeholder that accepts one parameter' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be substituted into the output' do
      Object.class_eval @parser.compile %q{#def foo(string)
#echo string.downcase
#end
$foo("HELLO WORLD")}, :class_name => :PlaceholderSpecBeta
      expect(Walrus::Grammar::PlaceholderSpecBeta.new.fill).to eq("hello world")
    end
  end
end
