# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

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
