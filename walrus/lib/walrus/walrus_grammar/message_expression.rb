# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: message_expression.rb 165 2007-04-09 14:55:55Z wincent $

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class MessageExpression
      
      def compile(options = {})
        # simple case        
        @target.source_text + '.' + @message.source_text
      end
      
    end # class AssignmentExpression
    
  end # class WalrusGrammar
end # Walrus

