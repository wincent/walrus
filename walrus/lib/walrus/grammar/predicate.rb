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

require 'walrus'

module Walrus
  class Grammar
    
    # Predicates parse input without consuming it.
    # On success they throw a subclass-specific symbol (see the AndPredicate and NotPredicate classes).
    # On failure they raise a ParseError.
    class Predicate
      
      include Walrus::Grammar::ParsletCombining
      include Walrus::Grammar::Memoizing
      
      attr_reader :hash
      
      # Raises if parseable is nil.
      def initialize(parseable)
        raise ArgumentError if parseable.nil?
        @parseable = parseable
        @hash = @parseable.hash + hash_offset # fixed offset to avoid collisions with @parseable objects
      end
      
      def to_parseable
        self
      end
      
      def parse(string, options = {})
        raise NotImplementedError # subclass responsibility
      end
      
      def eql?(other)
        other.instance_of? self.class and other.parseable.eql? @parseable
      end
      
    protected
      
      # for equality comparisons
      attr_reader :parseable
      
    private
      
      def hash_offset
        10
      end
      
    end
    
  end # class Grammar
end # module Walrus
