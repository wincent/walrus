# Copyright 2007 Wincent Colaiuta
# $Id$

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
    
    context 'compiling an EchoDirective instance' do
      
      specify 'should be able to round trip' do
        @accumulator  = EchoDirectiveAccumulator.new
        @raw          = EchoDirective.new(SingleQuotedStringLiteral.new('hello world'))
        @accumulator.instance_eval(@raw.compile)
        @accumulator.content.should == 'hello world'
      end
      
    end
    
    context 'producing a Document containing an EchoDirective' do
      
      setup do
        @parser = Parser.new
      end
      
      specify 'should be able to round trip' do
        
        # simple example
        compiled = @parser.compile("#echo 'foo'", :class_name => :EchoDirectiveSpecAlpha)
        self.class.class_eval(compiled).should == 'foo'
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

