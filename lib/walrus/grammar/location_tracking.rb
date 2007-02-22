# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    # Methods for embedding location information in objects returned (or exceptions raised) from parse methods.
    module LocationTracking
      
      # To make it easier to calculate where we are in the input stream, keep track of how many columns we have moved to the right through the input since the last newline.
      attr_accessor :column_offset
      
      # To make it easier to calculate where we are in the input stream, keep track of how many lines we have moved down through in the input since initialization.
      attr_accessor :line_offset
      
      # Convenience method for setting both line_offset and column_offset at once.
      def offset=(array)
        raise ArgumentError if array.nil?
        raise ArgumentError if array.length != 2
        @line_offset    = array[0]
        @column_offset  = array[1]
        self
      end
      
      # Given an other object that responds to column_offset and line_offset, returns true if the receiver is rightmost or equal.
      # If the other object is farther to the right returns false.
      def righmost?(other)
        if @line_offset > other.line_offset         : true
        elsif other.line_offset > @line_offset      : false
        elsif @column_offset >= other.column_offset : true
        else                                          false
        end
      end
      
    end # module LocationTracking
    
  end # class Grammar
end # module Walrus
