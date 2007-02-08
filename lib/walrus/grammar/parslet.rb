# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    class Parslet
      
      require 'walrus/grammar/parslet_combining'
      include Walrus::Grammar::ParsletCombining
      
      def to_parseable
        self
      end
      
      def parse(string, options = {})
        raise NotImplementedError # subclass responsibility
      end
      
    end # class Parslet
  end # class Grammar
end # module Walrus
