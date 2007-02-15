# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    autoload(:SkippedSubstringException, 'walrus/grammar/skipped_substring_exception')
    
    require 'walrus/grammar/parslet_combination'
    class ParsletOmission < ParsletCombination
      
      attr_reader :hash
      
      # Raises an ArgumentError if parseable is nil.
      def initialize(parseable)
        raise ArgumentError if parseable.nil?
        @parseable = parseable
        @hash = @parseable.hash + 46 # fixed offset to avoid unwanted collisions with similar classes
      end
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        substring = ''
        
        # possibly should catch these here as well
        #catch :NotPredicateSuccess do
        #catch :AndPredicateSuccess do
        # one of the fundamental problems is that if a parslet throws such a symbol any info about already skipped material is lost (because the symbols contain nothing)
        # this may be one reason to change these to exceptions...
        catch :ZeroWidthParseSuccess do
          substring = @parseable.memoizing_parse(string, options).to_s
        end
        
        # not enough to just return a ZeroWidthParseSuccess here; that could cause higher levels to stop parsing and in any case there'd be no clean way to embed the scanned substring in the symbol
        raise SkippedSubstringException.new(substring)
      end
      
      def eql?(other)
        other.kind_of? ParsletOmission and other.parseable.eql? @parseable
      end
      
    protected
      
      # For determining equality.
      attr_reader :parseable
      
    end # class ParsletOmission
  end # class Grammar
end # module Walrus
