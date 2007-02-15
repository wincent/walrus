# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    require 'walrus/grammar/parslet_sequence'
    class ParsletMerge < ParsletSequence
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        state             = ParserState.new(string)
        last_caught       = nil # keep track of the last kind of throw to be caught
        augmented_options = options.clone
        augmented_options[:location] = 0 unless augmented_options.has_key? :location
        @components.each do |parseable|
          catch :ProcessNextAlternative do    # TODO: can I replace this using next?
            catch :NotPredicateSuccess do
              catch :AndPredicateSuccess do
                catch :ZeroWidthParseSuccess do
                  begin
                    starting_location = state.length  # remember current location within current ParserState instance
                    parsed = parseable.memoizing_parse(state.remainder, options)
                    if parsed.respond_to? :each : parsed.each { |element| state.parsed(element) }
                    else                          state.parsed(parsed)
                    end
                    state.skipped(parsed.omitted.to_s)  # in case any sub-parslets skipped tokens along the way
                    augmented_options[:location] = augmented_options[:location] + (state.length - starting_location)
                  rescue SkippedSubstringException => e
                    state.skipped(e.to_s)
                    augmented_options[:location] = augmented_options[:location] + (state.length - starting_location)
                  # TODO: possiby try inter-token parslets on failure here? (have yet to find a failing spec that requires this)
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
      
      def eql?(other)
        return false if not other.kind_of? ParsletMerge
        other_components = other.components
        return false if @components.length != other_components.length
        for i in 0..(@components.length - 1)
          return false unless @components[i].eql? other_components[i]
        end
        true
      end
      
    private
      
      def hash_offset
        53
      end
      
    end # class ParsletMerge
  end # class Grammar
end # module Walrus

