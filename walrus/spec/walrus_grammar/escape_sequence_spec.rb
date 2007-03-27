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
    
    class EscapeSequenceAccumulator
      attr_reader :content
      def initialize
        @content = ''
      end
      def accumulate(string)
        @content << string
      end
    end
    
    context 'compiling an EscapeSequence instance' do
      
      setup do
        @accumulator  = EscapeSequenceAccumulator.new
      end
      
      specify 'should be able to round trip ($)' do
        sequence = EscapeSequence.new('$')
        @accumulator.instance_eval(sequence.compile)
        @accumulator.content.should == '$'
      end
      
      specify 'should be able to round trip (#)' do
        sequence = EscapeSequence.new('#')
        @accumulator.instance_eval(sequence.compile)
        @accumulator.content.should == '#'
      end
      
      specify 'should be able to round trip (\\)' do
        sequence = EscapeSequence.new('\\')
        @accumulator.instance_eval(sequence.compile)
        @accumulator.content.should == '\\'
      end
      
    end
    
    context 'producing a Document containing an EscapeSequence' do
      
      setup do
        @parser = Parser.new
      end
      
      specify 'should be able to round trip' do
        
        # single $
        sequence = @parser.compile('\\$', :class_name => :EscapeSequenceSpecAlpha)
        self.class.class_eval(sequence).should == '$'
        
        # single #
        sequence = @parser.compile('\\#', :class_name => :EscapeSequenceSpecBeta)
        self.class.class_eval(sequence).should == '#'
        
        # single \
        sequence = @parser.compile('\\\\', :class_name => :EscapeSequenceSpecDelta)
        self.class.class_eval(sequence).should == '\\'
        
        # multiple escape markers
        sequence = @parser.compile('\\\\\\#\\$', :class_name => :EscapeSequenceSpecGamma)
        self.class.class_eval(sequence).should == '\\#$'
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

