# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: slurp_directive.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus/parser.rb' # make sure that the class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class SlurpDirective
      
      # The slurp directive produces no meaningful output; but we leave a comment in the compiled template so that the location of the directive is visible in the source.
      def compile(options = {})
        "# Slurp directive\n"
      end
      
    end # class SlurpDirective
    
  end # class WalrusGrammar
end # Walrus

