# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    autoload(:ParserState, 'walrus/grammar/parser_state')
    autoload(:SkippedSubstringException, 'walrus/grammar/skipped_substring_exception')
    
    require 'walrus/grammar/parslet_combination'
    class ParsletSequence < ParsletCombination
      
      # first and second may not be nil.
      def initialize(first, second, *others)
        raise ArgumentError if first.nil?
        raise ArgumentError if second.nil?
        @first  = first
        @second = second
        @others = others
      end
      
      # Override so that sequences are appended to an existing sequence:
      # Consider the following example:
      #     A & B
      # This constitutes a single sequence:
      #     (A & B)
      # If we then make this a three-element sequence:
      #     A & B & C
      # We are effectively creating an nested sequence containing the original sequence and an additional element:
      #     ((A & B) & C)
      # Although such a nested sequence is correctly parsed it produces unwanted nesting in the results because instead of returning a one-dimensional an array of results:
      #     [a, b, c]
      # It returns a nested array:
      #     [[a, b], c]
      # The solution to this unwanted nesting is to allowing appending to an existing sequence by using the private "<<" method.
      # This ensures that:
      #     A & B & C
      # Translates to a single sequence:
      #     (A & B & C)
      # And a single, uni-dimensional results array:
      #     [a, b, c]
      #
      def &(next_parslet)
        append(next_parslet)
      end
      
      def parse(string)
        raise ArgumentError if string.nil?
        state               = ParserState.new(string)
        last_caught         = nil # keep track of the last kind of throw to be caught
        alternatives        = [@first, @second] + @others
        alternatives.each do |parseable|
          catch(:ProcessNextAlternative) do
            catch(:NotPredicateSuccess) do
              catch(:AndPredicateSuccess) do
                catch(:ZeroWidthParseSuccess) do
                  begin
                    parsed = parseable.parse(state.remainder)
                    state.parsed(parsed)
                    state.skipped(parsed.omitted.to_s)  # in case any sub-parslets skipped tokens along the way
                  rescue SkippedSubstringException => e
                    state.skipped(e.to_s)
                  end
                  last_caught = nil
                  throw :ProcessNextAlternative
                end
                last_caught = :ZeroWidthParseSuccess
                throw :ProcessNextAlternative
              end
              last_caught = :AndPredicateSuccess
              throw :ProcessNextAlternative
            end
            last_caught = :NotPredicateSuccess
          end
        end
        
        if state.results.respond_to? :empty? and
           state.results.omitted.respond_to? :empty? and
           state.results.empty? and
           state.results.omitted.empty?
         throw last_caught
        else
         state.results
        end
        
      end
      
    private
      
      # Appends another Parslet (or ParsletCombination) to the receiver and returns the receiver.
      # Raises if parslet is nil.
      # Cannot use << as a method name because Ruby cannot parse it without the self, and self is not allowed as en explicit receiver for private messages.
      def append(next_parslet)
        raise ArgumentError if next_parslet.nil?
        @others << next_parslet.to_parseable
        self
      end
      
    end # class ParsletSequence
  end # class Grammar
end # module Walrus

