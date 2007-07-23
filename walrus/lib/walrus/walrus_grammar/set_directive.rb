# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: set_directive.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class SetDirective
      
      def compile(options = {})
        "set_value(%s, instance_eval { %s }) # Set directive \n" % [ @placeholder.to_s.dump, @expression.compile ]
      end
      
    end # class SetDirective
    
  end # class WalrusGrammar
end # Walrus

