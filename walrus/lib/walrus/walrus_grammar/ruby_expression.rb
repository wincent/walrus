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
# $Id: ruby_expression.rb 165 2007-04-09 14:55:55Z wincent $

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
        source_text
      end
      
    end # class AssignmentExpression
    
  end # class WalrusGrammar
end # Walrus

