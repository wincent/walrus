# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class RubyExpression
      
      # Rather than just compiling Ruby expressions back to text in a generic fashion it is desirable
      # to compile the pieces separately (for an example, see the AssignmentExpression class) because
      # this allows us to handle placeholders embedded inside Ruby expressions.
      #
      # Nevertheless, at an abstract level we here supply a default compilation method which just
      # returns the source text, suitable for evaluation. Subclasses can then override this as new
      # cases are discovered which require piece-by-piece compilation.
      def compile(options = {})
        #puts "this is what we return"
        #p @source_text
        source_text
      end
      
    end # class AssignmentExpression
    
  end # class WalrusGrammar
end # Walrus

