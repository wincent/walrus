# Copyright 2007 Wincent Colaiuta
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id: literal_spec.rb 166 2007-04-09 15:04:40Z wincent $

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  class WalrusGrammar
    
    describe 'compiling a double-quoted string literal instance' do
      
      it 'should produce a string literal' do
        string = StringResult.new('hello world')                  # construct the string result the same way the parser does
        string.source_text = '"hello world"'                      # the original source text includes the quotes
        compiled = DoubleQuotedStringLiteral.new(string).compile  # but the inner lexeme is just the contents
        compiled.should == '"hello world"'
        eval(compiled).should == 'hello world'
      end
      
    end
    
    describe 'compiling a single-quoted string literal instance' do
      
      it 'should produce a string literal' do
        string = StringResult.new('hello world')                  # construct the string result the same way the parser does
        string.source_text = "'hello world'"                      # the original source text includes the quotes
        compiled = SingleQuotedStringLiteral.new(string).compile  # but the inner lexeme is just the contents
        compiled.should == "'hello world'"
        eval(compiled).should == 'hello world'
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

