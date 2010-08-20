# Copyright 2007-2010 Wincent Colaiuta
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../spec_helper', File.dirname(__FILE__))

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
      eval @parser.compile('\\$', :class_name => :EscapeSequenceSpecAlpha)
      Walrus::Grammar::EscapeSequenceSpecAlpha.new.fill.should == '$'

      # single #
      eval @parser.compile('\\#', :class_name => :EscapeSequenceSpecBeta)
      Walrus::Grammar::EscapeSequenceSpecBeta.new.fill.should == '#'

      # single \
      eval @parser.compile('\\\\', :class_name => :EscapeSequenceSpecDelta)
      Walrus::Grammar::EscapeSequenceSpecDelta.new.fill.should == '\\'

      # multiple escape markers
      eval @parser.compile('\\\\\\#\\$', :class_name => :EscapeSequenceSpecGamma)
      Walrus::Grammar::EscapeSequenceSpecGamma.new.fill.should == '\\#$'
    end
  end
end
