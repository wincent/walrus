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
# $Id: parslet_repetition_default.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus'

module Walrus
  class Grammar
    
    # ParsletRepetitionDefault is a subclass that modifies the behaviour of its parent, ParsletRepetition, in a very small way. Namely, if the outcome of parsing is a ZeroWidthParse success then it is caught and the default value (defined at initialization time) is returned instead.
    class ParsletRepetitionDefault < ParsletRepetition
      
      # Possible re-factoring to consider for the future: roll the functionality of this class in to ParsletRepetition itself.
      # Benefit of keeping it separate is that the ParsletRepetition itself is kept simple.
      def initialize(parseable, min, max = nil, default = nil)
        super(parseable, min, max)
        self.default  = default
      end
      
      def parse(string, options = {})
        catch :ZeroWidthParseSuccess do 
          return super(string, options) 
        end
        @default.clone rescue @default
      end
      
      def eql?(other)
        other.instance_of? ParsletRepetitionDefault and @min == other.min and @max == other.max and @parseable.eql? other.parseable and @default == other.default
      end
      
    protected
      
      # For determining equality.
      attr_reader :default
      
    private
      
      def hash_offset
        69
      end
      
      def update_hash
        @hash = super + @default.hash # let super calculate its share of the hash first
      end
      
      def default=(default)
        @default = (default.clone rescue default)
        @default.extend(LocationTracking)
        update_hash
      end
      
    end # class ParsletRepetitionDefault
  end # class Grammar
end # module Walrus
