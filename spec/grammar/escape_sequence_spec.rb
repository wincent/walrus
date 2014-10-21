# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe Walrus::Grammar::EscapeSequence do
  class Accumulator
    attr_reader :content
    def initialize
      @content = ''
    end
    def accumulate(string)
      @content << string
    end
  end

  context 'compiled' do
    before do
      @accumulator = Accumulator.new
    end

    it 'should be able to round trip ($)' do
      sequence = Walrus::Grammar::EscapeSequence.new('$')
      @accumulator.instance_eval(sequence.compile)
      @accumulator.content.should == '$'
    end

    it 'should be able to round trip (#)' do
      sequence = Walrus::Grammar::EscapeSequence.new('#')
      @accumulator.instance_eval(sequence.compile)
      @accumulator.content.should == '#'
    end

    it 'should be able to round trip (\\)' do
      sequence = Walrus::Grammar::EscapeSequence.new('\\')
      @accumulator.instance_eval(sequence.compile)
      @accumulator.content.should == '\\'
    end
  end

  describe 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be able to round trip' do
      # single $
      Object.class_eval @parser.compile('\\$', :class_name => :EscapeSequenceSpecAlpha)
      Walrus::Grammar::EscapeSequenceSpecAlpha.new.fill.should == '$'

      # single #
      Object.class_eval @parser.compile('\\#', :class_name => :EscapeSequenceSpecBeta)
      Walrus::Grammar::EscapeSequenceSpecBeta.new.fill.should == '#'

      # single \
      Object.class_eval @parser.compile('\\\\', :class_name => :EscapeSequenceSpecDelta)
      Walrus::Grammar::EscapeSequenceSpecDelta.new.fill.should == '\\'

      # multiple escape markers
      Object.class_eval @parser.compile('\\\\\\#\\$', :class_name => :EscapeSequenceSpecGamma)
      Walrus::Grammar::EscapeSequenceSpecGamma.new.fill.should == '\\#$'
    end
  end
end
