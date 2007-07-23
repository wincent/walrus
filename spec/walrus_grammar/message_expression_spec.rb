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

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  class WalrusGrammar
    
    describe 'calling source_text on a message expression inside an echo directive' do
      
      before(:each) do
        @parser = Parser.new
      end
      
      it 'should return the text of the expression only' do
        
        directive = @parser.parse '#echo string.downcase'
        directive.column_start.should == 0
        directive.expression.target.column_start.should == 6
        directive.expression.message.column_start.should == 13
        
        # ideally we'd report 6 here, but there is no way for Walrus to know that we don't want to count the skipped whitespace
        directive.expression.column_start.should == 5
        directive.expression.source_text.should == ' string.downcase'
        
      end
    end
    
  end # class WalrusGrammar
end # module Walrus

