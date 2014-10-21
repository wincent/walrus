# encoding: utf-8
# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe Walrus::Grammar::RawText do
  class Accumulator
    attr_reader :content
    def initialize
      @content = ''
    end
    def accumulate(string)
      @content << string
    end
  end

  describe 'compiling' do
    it 'should be able to round trip' do
      @accumulator  = Accumulator.new
      @raw_text     = Walrus::Grammar::RawText.new('hello \'world\'\\... €')
      @accumulator.instance_eval(@raw_text.compile)
      expect(@accumulator.content).to eq('hello \'world\'\\... €')
    end
  end

  describe 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be able to round trip' do
      # simple example
      Object.class_eval @parser.compile('hello world', :class_name => :RawTextSpecAlpha)
      expect(Walrus::Grammar::RawTextSpecAlpha.new.fill).to eq('hello world')

      # containing single quotes
      Object.class_eval @parser.compile("hello 'world'", :class_name => :RawTextSpecBeta)
      expect(Walrus::Grammar::RawTextSpecBeta.new.fill).to eq("hello 'world'")

      # containing a newline
      Object.class_eval @parser.compile("hello\nworld", :class_name => :RawTextSpecDelta)
      expect(Walrus::Grammar::RawTextSpecDelta.new.fill).to eq("hello\nworld")
    end
  end
end
