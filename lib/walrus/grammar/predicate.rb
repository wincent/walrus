# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    # Predicates parse input without consuming it.
    # On success they throw a subclass-specific symbol (see the AndPredicate and NotPredicate classes).
    # On failure they raise a ParseError.
    class Predicate
      
      require 'walrus/grammar/parslet_combining'
      include Walrus::Grammar::ParsletCombining
      
      # Raises if parseable is nil.
      def initialize(parseable)
        raise ArgumentError if parseable.nil?
        @parseable = parseable
      end
      
      def to_parseable
        self
      end
      
      def parse
        raise NotImplementedError # subclass responsibility
      end
      
    end
    
  end # class Grammar
end # module Walrus
