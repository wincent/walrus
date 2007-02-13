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
                    if parsed.respond_to? :each : parsed.each { |element| state.parsed(element) }
                    else                          state.parsed(parsed)
                    end
                    state.skipped(parsed.omitted.to_s)  # in case any sub-parslets skipped tokens along the way
                  rescue SkippedSubstringException => e
                    state.skipped(e.to_s)
                  # TODO: possiby try inter-token parslets on failure here? (have yet to find a failing spec that requires this)
#                  rescue ParseError => e # failed, will try to skip; save original error in case skipping fails                    
#                    skipping_parslet = nil
#                    if options.has_key?(:skipping_override) : skipping_parslet = options[:skipping_override]
#                    elsif options.has_key?(:skipping)       : skipping_parslet = options[:skipping]
#                    end
#                    if skipping_parslet
#                      begin
#                        parsed = skipping_parslet.parse(state.remainder, options) # potentially guard against self references (possible infinite recursion) here
#                        puts "skipping worked!"
#                      rescue ParseError
#                        raise e # skipping didn't help either, raise original error
#                      end
#                      state.skipped(parsed)
#                      state.skipped(parsed.omitted.to_s)
#                      redo # skipping succeeded, try to redo
#                    end
#                    raise e # no skipper defined, raise original error
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

