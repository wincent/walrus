# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    autoload(:ParserState, 'walrus/grammar/parser_state')
    autoload(:SkippedSubstringException, 'walrus/grammar/skipped_substring_exception')
    
    require 'walrus/grammar/parslet_combination'
    class ParsletRepetition < ParsletCombination
      
      # Raises an ArgumentError if parseable or min is nil.
      def initialize(parseable, min, max = nil)
        raise ArgumentError if parseable.nil?
        raise ArgumentError if min.nil?
        @parseable = parseable
        self.min = min
        self.max = max
      end
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        state     = ParserState.new(string)
        
        catch(:ZeroWidthParseSuccess) do          # a zero-width match is grounds for immediate abort
          while @max.nil? or state.count < @max   # try forever if max is nil; otherwise keep trying while match count < max
            begin
              parsed = @parseable.parse(state.remainder, options)
              state.parsed(parsed)
              state.skipped(parsed.omitted.to_s)  # in case any sub-parslets skipped tokens along the way
            rescue SkippedSubstringException => e
              state.skipped(e.to_s)
            rescue ParseError
              break # give up
            end
          end          
        end
        
        # now assess whether our tries met the requirements
        if state.count == 0 and @min == 0 # success (special case)
          throw :ZeroWidthParseSuccess
        elsif state.count < @min          # matches < min (failure)
          raise ParseError.new('required %d matches but obtained %d while parsing "%s"' % [@min, state.count, string])
        else                              # success (general case)
          state.results                   # returns multiple matches as an array, single matches as a single object
        end
        
      end
      
    private
      
      def min=(min)
        @min = (min.clone rescue min)
      end
      
      def max=(max)
        @max = (max.clone rescue max)
      end
      
    end # class ParsletRepetition
  end # class Grammar
end # module Walrus
