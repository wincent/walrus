# Copyright 2007 Wincent Colaiuta
# $Id$

require 'strscan'

module Walrus
  class Grammar
    
    # Unicode-aware (UTF-8) string enumerator.
    class StringEnumerator
      
      def initialize(string)
        raise ArgumentError if string.nil?
        @scanner = StringScanner.new(string)
      end
      
      def next
        old_kcode = $KCODE
        $KCODE    = "U"     # UTF-8
        char      = @scanner.scan(/./m) # must use multiline mode or "." won't match newlines
        $KCODE    = old_kcode
        char
      end
      
    end # class StringEnumerator
    
  end # class Grammar
end # module Walrus
