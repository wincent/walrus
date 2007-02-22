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
        @line_offset    = info[:line_offset] or 0
        @column_offset  = info[:column_offset] or 0
      end
      
    end # class ParseError
    
  end # class Grammar
end # module Walrus

