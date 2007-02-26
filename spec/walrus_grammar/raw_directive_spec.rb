# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  class WalrusGrammar
    
    class RawDirectiveAccumulator
      attr_reader :content
      def initialize
        @content = ''
      end
      def accumulate(string)
        @content << string
      end
    end
    
    context 'compiling a RawDirective instance' do
      
      specify 'should be able to round trip' do
        @accumulator  = RawDirectiveAccumulator.new
        @raw          = RawDirective.new('hello \'world\'\\... € #raw, $raw, \\raw')
        @accumulator.instance_eval(@raw.compile)
        @accumulator.content.should == 'hello \'world\'\\... € #raw, $raw, \\raw'
      end
      
    end
    
    context 'producing a Document containing RawText' do
      
      setup do
        @parser = Parser.new
      end
      
      specify 'should be able to round trip' do
        
        # simple example
        raw = @parser.compile("#raw\nhello world\n#end", :class_name => :RawDirectiveSpecAlpha)
        self.class.class_eval(raw).should == "hello world\n"
        
        # containing single quotes
        raw = @parser.compile("#raw\nhello 'world'\n#end", :class_name => :RawDirectiveSpecBeta)
        self.class.class_eval(raw).should == "hello 'world'\n"
        
        # containing a newline
        raw = @parser.compile("#raw\nhello\nworld\n#end", :class_name => :RawDirectiveSpecDelta)
        self.class.class_eval(raw).should == "hello\nworld\n"
        
        # using a "here document"
        raw = @parser.compile("#raw <<HERE
hello world
literal #end with no effect
HERE", :class_name => :RawDirectiveSpecGamma)
        self.class.class_eval(raw).should == "hello world\nliteral #end with no effect\n"
        
        # "here document", alternative syntax
        raw = @parser.compile("#raw <<-HERE
hello world
literal #end with no effect
        HERE", :class_name => :RawDirectiveSpecIota)
        self.class.class_eval(raw).should == "hello world\nliteral #end with no effect\n"
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

