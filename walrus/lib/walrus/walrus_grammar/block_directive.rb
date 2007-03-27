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
    
    class BlockDirective
      
      # Returns a string containing the compiled (Ruby) version of receiver.
      def compile(options = {})
        inner, outer = super
        inner = '' if inner.nil?
        inner << "lookup_and_accumulate_placeholder(#{@identifier.to_s.to_sym.inspect})\n"
        [inner, outer]
      end
      
    end # class BlockDirective
    
  end # class WalrusGrammar
end # Walrus

