# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: escape_sequence_spec.rb 192 2007-05-03 09:27:35Z wincent $

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
    
    describe 'compiling an EscapeSequence instance' do
      
      before(:each) do
        @accumulator  = EscapeSequenceAccumulator.new
      end
      
      it 'should be able to round trip ($)' do
        sequence = EscapeSequence.new('$')
        @accumulator.instance_eval(sequence.compile)
        @accumulator.content.should == '$'
      end
      
      it 'should be able to round trip (#)' do
        sequence = EscapeSequence.new('#')
        @accumulator.instance_eval(sequence.compile)
        @accumulator.content.should == '#'
      end
      
      it 'should be able to round trip (\\)' do
        sequence = EscapeSequence.new('\\')
        @accumulator.instance_eval(sequence.compile)
        @accumulator.content.should == '\\'
      end
      
    end
    
    describe 'producing a Document containing an EscapeSequence' do
      
      before(:each) do
        @parser = Parser.new
      end
      
      it 'should be able to round trip' do
        
        # single $
        sequence = @parser.compile('\\$', :class_name => :EscapeSequenceSpecAlpha)
        self.class.class_eval(sequence)
        self.class::Walrus::WalrusGrammar::EscapeSequenceSpecAlpha.new.fill.should == '$'
        
        # single #
        sequence = @parser.compile('\\#', :class_name => :EscapeSequenceSpecBeta)
        self.class.class_eval(sequence)
        self.class::Walrus::WalrusGrammar::EscapeSequenceSpecBeta.new.fill.should == '#'
        
        # single \
        sequence = @parser.compile('\\\\', :class_name => :EscapeSequenceSpecDelta)
        self.class.class_eval(sequence)
        self.class::Walrus::WalrusGrammar::EscapeSequenceSpecDelta.new.fill.should == '\\'
        
        # multiple escape markers
        sequence = @parser.compile('\\\\\\#\\$', :class_name => :EscapeSequenceSpecGamma)
        self.class.class_eval(sequence)
        self.class::Walrus::WalrusGrammar::EscapeSequenceSpecGamma.new.fill.should == '\\#$'
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

