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
    
    class EscapeSequence
      
      def compile(options = {})
        "accumulate(%s) \# EscapeSequence\n" % @lexeme.to_s.dump
      end
      
    end
    
  end # class WalrusGrammar
end # Walrus
