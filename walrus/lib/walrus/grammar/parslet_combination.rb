# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: parslet_combination.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus'

module Walrus
  class Grammar
    
    class ParsletCombination
      
      include Walrus::Grammar::ParsletCombining
      include Walrus::Grammar::Memoizing
      
      def to_parseable
        self
      end
      
    end # module ParsletCombination
    
  end # class Grammar
end # module Walrus
