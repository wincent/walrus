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
    
    describe 'calling source_text on a message expression inside an echo directive' do
      
      setup do
        @parser = Parser.new
      end
      
      it 'should return the text of the expression only' do
        # this was a bug (was returning the entire directive): #echo string.downcase
        directive = @parser.parse '#echo string.downcase'
        directive.expression.source_text.should == 'string.downcase'
        
        # #<EchoDirective @column_end=21, @column_start=0, @line_end=0, @source_text="#echo string.downcase", @string_value="stringdowncase", @line_start=0, @expression=#<MessageExpression @column_end=21, @column_start=0, @message=#<MethodWithParentheses @column_end=21, @column_start=13, @name=#<Identifier @column_end=21, @column_start=13, @line_end=0, @source_text="downcase", @lexeme=#<Walrus::Grammar::MatchDataWrapper @column_end=21, @column_start=13, @match_data=#<MatchData @line_end=0, @source_text="downcase", @line_start=0>, @string_value="downcase", @line_start=0>, @line_end=0, @source_text="downcase", @params=[], @string_value="downcase", @line_start=0>, @line_end=0, @source_text="#echo string.downcase", @target=#<Identifier @column_end=12, @column_start=6, @line_end=0, @source_text="string", @lexeme=#<Walrus::Grammar::MatchDataWrapper @column_end=12, @column_start=6, @match_data=#<MatchData @line_end=0, @source_text="string", @line_start=0>, @string_value="string", @line_start=0>, @string_value="stringdowncase", @line_start=0>>
        
        
      end
    end
    
  end # class WalrusGrammar
end # module Walrus

