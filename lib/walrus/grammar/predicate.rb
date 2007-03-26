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
