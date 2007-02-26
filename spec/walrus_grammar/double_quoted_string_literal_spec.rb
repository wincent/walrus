# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  class WalrusGrammar
    
    context 'compiling a double-quoted string literal instance' do
      
      specify 'should produce a string literal' do
        string = StringResult.new('hello world')                  # construct the string result the same way the parser does
        string.source_text = '"hello world"'                      # the original source text includes the quotes
        compiled = DoubleQuotedStringLiteral.new(string).compile  # but the inner lexeme is just the contents
        compiled.should == '"hello world"'
        eval(compiled).should == 'hello world'
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

