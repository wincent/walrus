# Copyright 2007 Wincent Colaiuta
# $Id$

require 'strscan'
require 'walrus'

module Walrus
  class Grammar
    
    # Unicode-aware (UTF-8) string enumerator.
    # For Unicode support $KCODE must be set to 'U' (UTF-8).
    class StringEnumerator
      
      def initialize(string)
        raise ArgumentError if string.nil?
        @scanner = StringScanner.new(string)
      end
      
      # This method will only work as expected if $KCODE is set to 'U' (UTF-8).
      def next
        @scanner.scan(/./m) # must use multiline mode or "." won't match newlines
      end
      
    end # class StringEnumerator
    
  end # class Grammar
end # module Walrus
