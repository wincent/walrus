# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    # The MemoizingCache class memoizes the outcomes of parse operations. The functionality is implemented as a separate class so as to minimize the amount of "contamination" of other classes by memoizing code, and to allow memoizing to be cleanly turned on or off at will. If a MemoizingCache is passed to a Parslet, ParsletCombination or Predicate as a value for the :memoizer key in the options hash passed to a parse method, the class implementing that method will call the parse method on the cache rather than proceeding normally. The cache will either propagate the previously memoized result, or will defer back to the original class to obtain the result. A circular dependency is avoided by setting the :skip_memoizer flag in the options dictionary.
    # If no MemoizingCache is passed then normal program flow takes place.
    class MemoizingCache
      
      # Singleton class that serves as a default value for unset keys in a Hash.
      class NoValueForKey
        
        require 'singleton'
        include Singleton
        
        # Convenience method that returns a new Hash instance configured to return the NoValueForKey instance for unset keys.
        def self.hash
          Hash.new { |hash, key| hash[key] = NoValueForKey.instance }
        end
        
      end
      
      def initialize
        # The results of parse operations are stored (memoized) in a cache, keyed on the Parslet, ParsletCombination or Predicate used in the parse operation. For each key, the hash contains a hash of indices (keys) and parse results (values). The indices refer to the absolute position within the input stream at which the parsing operation took place. The values may be:
        #
        #   - ParseErrors raised during parsing
        #   - SkippedSubstringExceptions raised during parsing
        #   - :ZeroWidthParseSuccess symbols thrown during parsing
        #   - :AndPredicateSuccess symbols thrown during parsing
        #   - :NotPredicateSuccess symbols thrown during parsing
        #   - String instances returned as parse results
        #   - MatchDataWrapper instance returned as parse results
        #   - Array instances containing ordered collections of parse results
        #   - Node subclass instances containing AST productions
        #
        @cache = NoValueForKey.hash
      end
      
      # The receiver first checks the options dictionary for the values associated with the :location key (an absolute index within the input stream) and the :parseable key (expected to be a reference to a Parslet, ParsletCombination or Predicate instance) and checks whether there is already a stored result corresponding to that location and parseable in the cache. If found propogates the result directly to the caller rather than performing the parse method all over again. Here "propagation" means re-raising parse errors, re-throwing symbols, and returning object references. If not found, performs the parsing operation and stores the result in the cache before propagating it.
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        raise ArgumentError unless options.has_key? :location
        raise ArgumentError unless options.has_key? :parseable
        
        parseable, location = options[:parseable], options[:location]
        results = @cache[parseable]
        if results == NoValueForKey.instance      # nothing cached for parseable yet
          @cache[parseable] = NoValueForKey.hash  # set up new empty hash for use by parseable
        end
        
        # First check if we have seen this parseable/location combination before: if so, propagate result
        if (result = @cache[parseable][location]) != NoValueForKey.instance
          if result.kind_of? Symbol       : throw result
          elsif result.kind_of? Exception : raise result
          else                              return result
          end
        else # first time for this parseable/location combination, capture result and propagate
          catch :NotPredicateSuccess do
            catch :AndPredicateSuccess do
              catch :ZeroWidthParseSuccess do
                begin
                  options[:ignore_memoizer] = true
                  return @cache[parseable][location] = parseable.memoizing_parse(string, options) # store and return
                rescue Exception => e
                  raise @cache[parseable][location] = e                                           # store and re-raise
                end
              end
              throw @cache[parseable][location] = :ZeroWidthParseSuccess                          # store and re-throw
            end
            throw @cache[parseable][location] = :AndPredicateSuccess                              # store and re-throw
          end
          throw @cache[parseable][location] = :NotPredicateSuccess                                # store and re-throw
        end
      end
      
    end # class MemoizingCache
    
  end # class Grammar
end # module Walrus

