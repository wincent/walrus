# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe Walrus::Grammar::EchoDirective do
  class Accumulator
    attr_reader :content

    def initialize
      @content = ''
    end

    def accumulate string
      @content << string
    end
  end

  context 'compiled' do
    it 'should be able to round trip' do
      string              = Walrat::StringResult.new('hello world')
      string.source_text  = "'hello world'"
      @accumulator        = Accumulator.new
      @accumulator.instance_eval(Walrus::Grammar::EchoDirective.new(Walrus::Grammar::SingleQuotedStringLiteral.new(string)).compile)
      @accumulator.content.should == 'hello world'
    end

    # regression test for inputs that previously raised
    it 'should be able to recognize the short form' do
      @parser = Walrus::Parser.new
      expect do
        @parser.parse '#= Walrus::VERSION #'
      end.to_not raise_error
      expect do
        @parser.parse '<meta name="generator" content="Walrus #= Walrus::VERSION #">'
      end.to_not raise_error
    end
  end

  context 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be able to round trip' do
      # simple example
      Object.class_eval @parser.compile("#echo 'foo'", :class_name => :EchoDirectiveSpecAlpha)
      Walrus::Grammar::EchoDirectiveSpecAlpha.new.fill.should == 'foo'
    end

    it 'evaluates multiple expressions, but only accumulates the last' do
      Object.class_eval @parser.compile("#echo @foo = 1 + 2; @foo = @foo + 3; @foo",
                           :class_name => :EchoDirectiveSpecBeta)
      Walrus::Grammar::EchoDirectiveSpecBeta.new.fill.should == '6'
    end

    it 'evaluates multiple expressions in the same context' do
      # this means that local variables can be set in one expression in the
      # list and accessed by others in the list
      Object.class_eval @parser.compile("#echo foo = 1 + 2; foo = foo + 3; foo",
                           :class_name => :EchoDirectiveSpecDelta)
      Walrus::Grammar::EchoDirectiveSpecDelta.new.fill.should == '6'
    end
  end
end
