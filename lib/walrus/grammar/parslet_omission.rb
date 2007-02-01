# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    autoload(:SkippedSubstringException, 'walrus/grammar/skipped_substring_exception')
    
    require 'walrus/grammar/parslet_combination'
    class ParsletOmission < ParsletCombination
      
      # Raises an ArgumentError if parseable is nil.
      def initialize(parseable)
        raise ArgumentError if parseable.nil?
        @parseable = parseable
      end
      
      def parse(string)
        raise ArgumentError if string.nil?
        substring = ""
        catch(:ZeroWidthParseSuccess) do
          substring = @parseable.parse(string).to_s
        end
        
        # not enough to just return a ZeroWidthParseSuccess here; that could cause higher levels to stop parsing and in any case there'd be no way to embed the scanned substring in the symbol
        raise SkippedSubstringException.new(substring)
      end
      
    end # class ParsletOmission
  end # class Grammar
end # module Walrus
