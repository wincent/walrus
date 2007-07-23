# Copyright 2007 Wincent Colaiuta
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
#
# $Id: echo_directive_spec.rb 192 2007-05-03 09:27:35Z wincent $

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  class WalrusGrammar
    
    class EchoDirectiveAccumulator
      attr_reader :content
      def initialize
        @content = ''
      end
      def accumulate(string)
        @content << string
      end
    end
    
    describe 'compiling an EchoDirective instance' do
      
      it 'should be able to round trip' do
        string              = StringResult.new('hello world')
        string.source_text  = "'hello world'"
        @accumulator        = EchoDirectiveAccumulator.new
        @accumulator.instance_eval(EchoDirective.new(SingleQuotedStringLiteral.new(string)).compile)
        @accumulator.content.should == 'hello world'
      end
      
      # regression test for inputs that previously raised
      it 'should be able to recognize the short form' do
        @parser = Parser.new
        lambda { @parser.parse('#= Walrus::VERSION #') }.should_not raise_error
        lambda { @parser.parse('<meta name="generator" content="Walrus #= Walrus::VERSION #">') }.should_not raise_error
      end
      
    end
    
    describe 'producing a Document containing an EchoDirective' do
      
      before(:each) do
        @parser = Parser.new
      end
      
      it 'should be able to round trip' do
        
        # simple example
        compiled = @parser.compile("#echo 'foo'", :class_name => :EchoDirectiveSpecAlpha)
        self.class.class_eval(compiled)
        self.class::Walrus::WalrusGrammar::EchoDirectiveSpecAlpha.new.fill.should == 'foo'
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

