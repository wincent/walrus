# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: include_directive.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus/parser.rb' # make sure that the class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class IncludeDirective
      
      def compile(options = {})
        inner, outer = options[:compiler_instance].compile_subtree(subtree)
        inner = [] if inner.nil?
        inner.unshift "\# Include (start): #{file_name.to_s}:\n"
        [inner, outer]
      end
      
    end # class IncludeDirective
    
  end # class WalrusGrammar
end # Walrus

