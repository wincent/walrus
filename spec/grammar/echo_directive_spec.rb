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
      eval @parser.compile("#echo 'foo'", :class_name => :EchoDirectiveSpecAlpha)
      Walrus::Grammar::EchoDirectiveSpecAlpha.new.fill.should == 'foo'
    end
  end
end
