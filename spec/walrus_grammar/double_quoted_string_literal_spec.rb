# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  class WalrusGrammar
    
    context 'compiling a double-quoted string literal instance' do
      
      specify 'should produce a string literal' do
        compiled = DoubleQuotedStringLiteral.new('hello world').compile
        compiled.should == '"hello world"'
        eval(compiled).should == 'hello world'
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

