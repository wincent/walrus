# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    module LocationTracking
      
      # To make it easier to calculate where we are in the input stream, keep track of how many columns we have moved to the right through the input since the last newline.
      attr_reader :column_offset
      
      # To make it easier to calculate where we are in the input stream, keep track of how many lines we have moved down through in the input since initialization.
      attr_reader :line_offset
      
    end # module LocationTracking
    
  end # class Grammar
end # module Walrus
