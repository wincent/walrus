# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/walrus_grammar/raw_text'

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
      
      specify 'should be able to round trip' do
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

