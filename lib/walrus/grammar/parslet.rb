# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    class Parslet
      
      include Walrus::Grammar::ParsletCombining
      include Walrus::Grammar::LocationTracking
      include Walrus::Grammar::Memoizing
      
      def initialize
        @column_offset  = 0
        @line_offset    = 0
      end
      
      def to_parseable
        self
      end
      
      def parse(string, options = {})
        raise NotImplementedError # subclass responsibility
      end
      
    end # class Parslet
  end # class Grammar
end # module Walrus
