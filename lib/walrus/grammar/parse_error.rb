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
        self.line_offset    = info[:line_offset]
        self.column_offset  = info[:column_offset]
        @rightmost          = info[:rightmost]           # (optional) rightmost exception that was thrown by a sub-parser while trying to parse
      end
      
      # TODO: potentially offer a "rightmost" method that recursively checks to see what is the rightmost subparser error (or subsubsubparser error)
      
    end # class ParseError
    
  end # class Grammar
end # module Walrus

