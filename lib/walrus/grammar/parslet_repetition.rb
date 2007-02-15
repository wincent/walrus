# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    autoload(:ParserState, 'walrus/grammar/parser_state')
    autoload(:SkippedSubstringException, 'walrus/grammar/skipped_substring_exception')
    
    require 'walrus/grammar/parslet_combination'
    class ParsletRepetition < ParsletCombination
      
      attr_reader :hash
      
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
        state             = ParserState.new(string)
        augmented_options = options.clone
        augmented_options[:location] = 0 unless augmented_options.has_key? :location
        
        catch :ZeroWidthParseSuccess do          # a zero-width match is grounds for immediate abort
          while @max.nil? or state.count < @max   # try forever if max is nil; otherwise keep trying while match count < max
            begin
              starting_location = state.length  # remember current location within current ParserState instance
              parsed = @parseable.memoizing_parse(state.remainder, augmented_options)
              state.parsed(parsed)
              state.skipped(parsed.omitted.to_s)  # in case any sub-parslets skipped tokens along the way
              augmented_options[:location] = augmented_options[:location] + (state.length - starting_location)
            rescue SkippedSubstringException => e
              state.skipped(e.to_s)
              augmented_options[:location] = augmented_options[:location] + (state.length - starting_location)
            rescue ParseError => e # failed, will try to skip; save original error in case skipping fails
              skipping_parslet = nil
              if augmented_options.has_key?(:skipping_override) : skipping_parslet = augmented_options[:skipping_override]
              elsif augmented_options.has_key?(:skipping)       : skipping_parslet = augmented_options[:skipping]
              end
              if skipping_parslet
                begin
                  parsed = skipping_parslet.memoizing_parse(state.remainder, augmented_options) # guard against self references (possible infinite recursion) here?
                rescue ParseError
                  break # skipping didn't help either, raise original error
                end
                state.skipped(parsed)
                state.skipped(parsed.omitted.to_s)
                augmented_options[:location] = augmented_options[:location] + (state.length - starting_location)
                redo # skipping succeeded, try to redo
              end
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
      
      def eql?(other)
        other.kind_of? ParsletRepetition and @min == other.min and @max == other.max and @parseable.eql? other.parseable
      end
      
    protected
      
      # For determining equality.
      attr_reader :parseable, :min, :max
      
    private
      
      def update_hash
        @hash = @min.hash + @max.hash + @parseable.hash + 87 # fixed offset to minimize risk of collisions
      end
      
      def min=(min)
        @min = (min.clone rescue min)
        update_hash
      end
      
      def max=(max)
        @max = (max.clone rescue max)
        update_hash
      end
      
    end # class ParsletRepetition
  end # class Grammar
end # module Walrus
