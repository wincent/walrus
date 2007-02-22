# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    # Methods for embedding location information in objects returned (or exceptions raised) from parse methods.
    # To make it easier to calculate where we are in the input stream, keep track of how many columns we have moved to the right through the input since the last newline.
    # To make it easier to calculate where we are in the input stream, keep track of how many lines we have moved down through in the input since initialization.
    module LocationTracking
      
      # Sets @column_offset to offset.
      # Sets @column_offset to 0 if passed nil (for ease of use, users of classes that mix-in this module don't have to worry about special casing nil values).
      def column_offset=(offset)
        @column_offset = offset || 0
      end
      
      # Returns 0 if @column_offset is nil (for ease of use, users of classes that mix-in this module don't have to worry about special casing nil values).
      def column_offset
        @column_offset || 0
      end
      
      # Sets @line_offset to offset.
      # Sets @line_offset to 0 if passed nil (for ease of use, users of classes that mix-in this module don't have to worry about special casing nil values).
      def line_offset=(offset)
        @line_offset = offset || 0
      end
      
      # Returns 0 if @line_offset is nil (for ease of use, users of classes that mix-in this module don't have to worry about special casing nil values).
      def line_offset
        @line_offset || 0
      end
      
      # Convenience method for setting both line_offset and column_offset at once.
      def offset=(array)
        raise ArgumentError if array.nil?
        raise ArgumentError if array.length != 2
        self.line_offset    = array[0]
        self.column_offset  = array[1]
      end
      
      # Given another object that responds to column_offset and line_offset, returns true if the receiver is rightmost or equal.
      # If the other object is farther to the right returns false.
      def rightmost?(other)
        if self.line_offset > other.line_offset         : true
        elsif other.line_offset > self.line_offset      : false
        elsif self.column_offset >= other.column_offset : true
        else                                              false
        end
      end
      
    end # module LocationTracking
    
  end # class Grammar
end # module Walrus
