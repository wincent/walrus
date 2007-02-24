# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    class ParseError < Exception
      
      include Walrus::Grammar::LocationTracking
      
      # Takes an optional hash (for packing extra info into exception).
      # position in string (irrespective of line number, column number)
      # line number, column number
      # filename
      def initialize(message, info = {})
        super message
        self.line_start     = info[:line_start]
        self.column_start   = info[:column_start]
        self.line_end       = info[:line_end]
        self.column_end     = info[:column_end]
      end
      
      def inspect
        # TODO also return filename if available
        '#<%s: %s @line_end=%d, @column_end=%d>' % [ self.class.to_s, self.to_s, self.line_end, self.column_end ]
      end
      
    end # class ParseError
    
  end # class Grammar
end # module Walrus

