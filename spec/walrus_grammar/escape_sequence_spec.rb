# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser'

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
        @parser = Parser.new()
      end
      
      specify 'should be able to round trip' do
        
        # single $
        sequence = @parser.compile('\\$')
        eval(sequence).should == '$'
        
        # single #
        sequence = @parser.compile('\\#')
        eval(sequence).should == '#'
        
        # single \
        sequence = @parser.compile('\\\\')
        eval(sequence).should == '\\'
        
        # multiple escape markers
        sequence = @parser.compile('\\\\\\#\\$')
        eval(sequence).should == '\\#$'
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

