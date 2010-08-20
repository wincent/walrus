# encoding: utf-8
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
      @accumulator.content.should == 'hello \'world\'\\... €'
    end
  end

  describe 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be able to round trip' do
      # simple example
      eval @parser.compile('hello world', :class_name => :RawTextSpecAlpha)
      Walrus::Grammar::RawTextSpecAlpha.new.fill.should == 'hello world'

      # containing single quotes
      eval @parser.compile("hello 'world'", :class_name => :RawTextSpecBeta)
      Walrus::Grammar::RawTextSpecBeta.new.fill.should == "hello 'world'"

      # containing a newline
      eval @parser.compile("hello\nworld", :class_name => :RawTextSpecDelta)
      Walrus::Grammar::RawTextSpecDelta.new.fill.should == "hello\nworld"
    end
  end
end
