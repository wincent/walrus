# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    autoload(:ContinuationWrapperException, 'walrus/grammar/continuation_wrapper_exception')
    
    require 'walrus/grammar/parslet'
    
    # A SymbolParslet allows for evaluation of a parslet to be deferred until runtime (or parse time, to be more precise).
    class SymbolParslet < Parslet
      
      def initialize(symbol)
        raise ArgumentError if symbol.nil?
        @symbol = symbol
      end
      
      # SymbolParslets don't actually know what Grammar they are associated with at the time of their definition. They expect the Grammar to be passed in with the options hash under the ":grammar" key.
      # Raises if string is nil, or if the options hash does not include a :grammar key.
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        raise ArgumentError unless options.has_key?(:grammar)
        grammar = options[:grammar]
        augmented_options = options.clone
        augmented_options[:rule_name] = @symbol
        result = grammar.rules[@symbol].parse(string, augmented_options)
        return grammar.wrap(result, @symbol)
        
        # TODO: potentially rescue ParseError here and try the skipping parslet, if there is one, and if there is no self-referential recursion...
        # i tried this and it broke some specs so I am not going to switch to this code because there doesn't yet seem to be a compelling reason
        state = ParserState.new(string)
        1.times do
          puts "top"
          begin
            result = grammar.rules[@symbol].parse(state.remainder, augmented_options)
            state.parsed(result)
            state.skipped(result.omitted.to_s)
          rescue ParseError => e
            
            # TODO: do the same here as I did in parslet_repetition (check for overrides)
            skipping_parslet = nil
            if options.has_key?(:rule_name) and options[:grammar].skipping_overrides.has_key?(options[:rule_name])
              skipping_parslet = options[:grammar].skipping_overrides[options[:rule_name]]
            elsif options.has_key?(:skipping)
              skipping_parslet = options[:skipping]
            end
            #if skipping_parslet...
              
            if options.has_key?(:skipping) and not options[:skipping].nil? and options[:skipping] != @symbol
              begin
                result = options[:skipping].parse(state.remainder, augmented_options)
              rescue ParseError
                raise e # skipping didn't help either, re-raise the original error
              end
              state.parsed(result)
              state.skipped(result.omitted.to_s)
              puts "retrying"
              redo # skipping succeeded, try again
            else
              raise e # no suitable skipper defined, re-raise the original error
            end
          end
        end
        grammar.wrap(state.results, @symbol)
        
        
        
        
        
      end
      
    end # class SymbolParslet
    
  end # class Grammar
end # module Walrus

