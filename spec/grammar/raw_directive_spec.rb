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

describe Walrus::Grammar::RawDirective do
  class Accumulator
    attr_reader :content
    def initialize
      @content = ''
    end
    def accumulate(string)
      @content << string
    end
  end

  describe 'compiling a RawDirective instance' do
    it 'should be able to round trip' do
      @accumulator  = Accumulator.new
      @raw          = Walrus::Grammar::RawDirective.new('hello \'world\'\\... € #raw, $raw, \\raw')
      @accumulator.instance_eval(@raw.compile)
      @accumulator.content.should == 'hello \'world\'\\... € #raw, $raw, \\raw'
    end
  end

  describe 'producing a Document containing RawText' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be able to round trip' do
      # simple example
      eval @parser.compile "#raw\nhello world\n#end",
        :class_name => :RawDirectiveSpecAlpha
      Walrus::Grammar::RawDirectiveSpecAlpha.new.fill.should == "hello world\n"

      # containing single quotes
      eval @parser.compile "#raw\nhello 'world'\n#end",
        :class_name => :RawDirectiveSpecBeta
      Walrus::Grammar::RawDirectiveSpecBeta.new.fill.should == "hello 'world'\n"

      # containing a newline
      eval @parser.compile "#raw\nhello\nworld\n#end",
        :class_name => :RawDirectiveSpecDelta
      Walrus::Grammar::RawDirectiveSpecDelta.new.fill.should == "hello\nworld\n"

      # using a "here document"
      eval @parser.compile "#raw <<HERE
hello world
literal #end with no effect
HERE", :class_name => :RawDirectiveSpecGamma
      Walrus::Grammar::RawDirectiveSpecGamma.new.fill.should == "hello world\nliteral #end with no effect\n"

      # "here document", alternative syntax
      eval @parser.compile "#raw <<-HERE
hello world
literal #end with no effect
      HERE", :class_name => :RawDirectiveSpecIota
      Walrus::Grammar::RawDirectiveSpecIota.new.fill.should == "hello world\nliteral #end with no effect\n"
    end
  end
end
