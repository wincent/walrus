# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: super_directive.rb 171 2007-04-09 18:59:29Z wincent $

require 'walrus/parser.rb' # make sure that the class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class SuperDirective
      
      def compile(options = {})
        
        # basic case, no explicit parameters
        "super # Super directive\n"
        
      end
      
    end # class SuperDirective
    
  end # class WalrusGrammar
end # Walrus

