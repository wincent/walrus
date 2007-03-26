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
    
    context 'compiling a double-quoted string literal instance' do
      
      specify 'should produce a string literal' do
        string = StringResult.new('hello world')                  # construct the string result the same way the parser does
        string.source_text = '"hello world"'                      # the original source text includes the quotes
        compiled = DoubleQuotedStringLiteral.new(string).compile  # but the inner lexeme is just the contents
        compiled.should == '"hello world"'
        eval(compiled).should == 'hello world'
      end
      
    end
    
    context 'compiling a single-quoted string literal instance' do
      
      specify 'should produce a string literal' do
        string = StringResult.new('hello world')                  # construct the string result the same way the parser does
        string.source_text = "'hello world'"                      # the original source text includes the quotes
        compiled = SingleQuotedStringLiteral.new(string).compile  # but the inner lexeme is just the contents
        compiled.should == "'hello world'"
        eval(compiled).should == 'hello world'
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

