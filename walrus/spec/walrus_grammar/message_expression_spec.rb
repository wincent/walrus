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
        directive = @parser.parse '#echo string.downcase'
        directive.column_start.should == 0
        directive.expression.target.column_start.should == 6
        directive.expression.message.column_start.should == 13
        
        # here things start to go wrong
        #directive.expression.column_start.should == 6                 # => 0
        #directive.expression.source_text.should == 'string.downcase'  # => #echo string.downcase
        # although note that directive.expression.string_value is "stringdowncase" (note that #echo isn't present here)
        # manually fixing the column start (for example, by patching location_tracking.rb to disallow moving the column_start backwards) 
        # doesn't fix the source_text bug, so these are definitely two separate issues
        #
        # see notes on this issue in "notes/colstart_sourcetext_bug.txt" on attempts to track this down:
        # summary:
        # the MessageExpression is correct at the time it is wrapped
        # but by the time state.results is called inside ParsletSequence,
        # just before EchoDirective is wrapped, the col start gets set back to 0
        # as a side effect this seems to ruin the "source_text" instance variable as well
      end
    end
    
  end # class WalrusGrammar
end # module Walrus

