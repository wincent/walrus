# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser'

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
    
    context 'compiling a RawText instance' do
      
      specify 'should be able to round trip' do
        @accumulator  = RawTextAccumulator.new
        @raw_text     = RawText.new('hello \'world\'\\... €')
        @accumulator.instance_eval(@raw_text.compile)
        @accumulator.content.should == 'hello \'world\'\\... €'
      end
      
    end
    
    context 'producing a Document containing RawText' do
      
      setup do
        @parser = Parser.new
      end
      
      specify 'should be able to round trip' do
        
        # simple example
        raw_text = @parser.compile('hello world', :class_name => :RawTextSpecAlpha)
        eval(raw_text).should == 'hello world'
        
        # containing single quotes
        raw_text = @parser.compile("hello 'world'", :class_name => :RawTextSpecBeta)
        eval(raw_text).should == "hello 'world'"
        
        # containing a newline
        raw_text = @parser.compile("hello\nworld", :class_name => :RawTextSpecDelta)
        eval(raw_text).should == "hello\nworld"
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

