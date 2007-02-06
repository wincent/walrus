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
      
      # SymbolParslets are basically context-free until the first time they are used. That is, in order to keep the interface clean and make it easy and neat to reference symbols when defining rules for a grammar, SymbolParslets don't actually know what Grammar they are associated with at the time of their definition. The first time they are used (the first time the parse method is invoked) they throw a ContinuationWrapperException which can be caught by the grammar; the grammar uses the wrapped continuation object to resume execution at the point where the exception was thrown, passing back a reference to the grammar so that the SymbolParslet can proceed with the lookup. The parslet also remembers the passed-in grammar instance so that in subsequent uses the convoluted look-up isn't necessary.
      # Raises if string is nil, or if the options hash does not include a :grammar key.
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        raise ArgumentError unless options.has_key?(:grammar)
        options[:grammar].rules[@symbol].parse(string, options)
      end
      
    end # class SymbolParslet
    
  end # class Grammar
end # module Walrus

