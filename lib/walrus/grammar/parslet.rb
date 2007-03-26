# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require 'walrus'

module Walrus
  class Grammar
    class Parslet
      
      include Walrus::Grammar::ParsletCombining
      include Walrus::Grammar::Memoizing
      
      def to_parseable
        self
      end
      
      def parse(string, options = {})
        raise NotImplementedError # subclass responsibility
      end
      
    end # class Parslet
  end # class Grammar
end # module Walrus
