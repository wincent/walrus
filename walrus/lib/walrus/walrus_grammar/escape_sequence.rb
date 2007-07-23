# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: escape_sequence.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class EscapeSequence
      
      def compile(options = {})
        "accumulate(%s) \# EscapeSequence\n" % @lexeme.to_s.dump
      end
      
    end
    
  end # class WalrusGrammar
end # Walrus

