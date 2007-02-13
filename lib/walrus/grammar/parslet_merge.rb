# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    require 'walrus/grammar/parslet_sequence'
    class ParsletMerge < ParsletSequence
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        state               = ParserState.new(string)
        last_caught         = nil # keep track of the last kind of throw to be caught
        alternatives        = [@first, @second] + @others
        alternatives.each do |parseable|
          catch :ProcessNextAlternative do
            catch :NotPredicateSuccess do
              catch :AndPredicateSuccess do
                catch :ZeroWidthParseSuccess do
                  begin
                    parsed = parseable.parse(state.remainder, options)
                    if parsed.respond_to? :each
                      parsed.each do |element|
                        state.parsed(element)
                        state.skipped(element.omitted.to_s)  # in case any sub-parslets skipped tokens along the way
                      end
                    else # MatchDataWrapper, for example, doesn't respond to "each"
                      state.parsed(parsed)
                      state.skipped(parsed.omitted.to_s)  # in case any sub-parslets skipped tokens along the way
                    end
                  rescue SkippedSubstringException => e
                    state.skipped(e.to_s)
                    # TODO: possiby try inter-token parslets on failure here?
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
      
    end # class ParsletMerge
  end # class Grammar
end # module Walrus

