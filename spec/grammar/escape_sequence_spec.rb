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
      expect(@accumulator.content).to eq('$')
    end

    it 'should be able to round trip (#)' do
      sequence = Walrus::Grammar::EscapeSequence.new('#')
      @accumulator.instance_eval(sequence.compile)
      expect(@accumulator.content).to eq('#')
    end

    it 'should be able to round trip (\\)' do
      sequence = Walrus::Grammar::EscapeSequence.new('\\')
      @accumulator.instance_eval(sequence.compile)
      expect(@accumulator.content).to eq('\\')
    end
  end

  describe 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be able to round trip' do
      # single $
      Object.class_eval @parser.compile('\\$', :class_name => :EscapeSequenceSpecAlpha)
      expect(Walrus::Grammar::EscapeSequenceSpecAlpha.new.fill).to eq('$')

      # single #
      Object.class_eval @parser.compile('\\#', :class_name => :EscapeSequenceSpecBeta)
      expect(Walrus::Grammar::EscapeSequenceSpecBeta.new.fill).to eq('#')

      # single \
      Object.class_eval @parser.compile('\\\\', :class_name => :EscapeSequenceSpecDelta)
      expect(Walrus::Grammar::EscapeSequenceSpecDelta.new.fill).to eq('\\')

      # multiple escape markers
      Object.class_eval @parser.compile('\\\\\\#\\$', :class_name => :EscapeSequenceSpecGamma)
      expect(Walrus::Grammar::EscapeSequenceSpecGamma.new.fill).to eq('\\#$')
    end
  end
end
