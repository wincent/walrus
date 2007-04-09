# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  class WalrusGrammar
    
    class RawTextAccumulator
      attr_reader :content
      def initialize
        @content = ''
      end
      def accumulate(string)
        @content << string
      end
    end
    
    describe 'compiling a RawText instance' do
      
      it 'should be able to round trip' do
        @accumulator  = RawTextAccumulator.new
        @raw_text     = RawText.new('hello \'world\'\\... €')
        @accumulator.instance_eval(@raw_text.compile)
        @accumulator.content.should == 'hello \'world\'\\... €'
      end
      
    end
    
    describe 'producing a Document containing RawText' do
      
      setup do
        @parser = Parser.new
      end
      
      it 'should be able to round trip' do
        
        # simple example
        raw_text = @parser.compile('hello world', :class_name => :RawTextSpecAlpha)
        self.class.class_eval(raw_text).should == 'hello world'
        
        # containing single quotes
        raw_text = @parser.compile("hello 'world'", :class_name => :RawTextSpecBeta)
        self.class.class_eval(raw_text).should == "hello 'world'"
        
        # containing a newline
        raw_text = @parser.compile("hello\nworld", :class_name => :RawTextSpecDelta)
        self.class.class_eval(raw_text).should == "hello\nworld"
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

