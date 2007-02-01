# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    autoload(:ContinuationWrapperException, 'walrus/grammar/continuation_wrapper_exception')
    
    attr_reader :rules
    
    # Creates a Grammar subclass named according to subclass_name and instantiates an instance of the new class, returning it after evaluating the optional block in the context of the newly created instance. The advantage of working inside a new subclass is that any constants defined in the new grammar will be in a separate namespace.
    # The subclass_name parameter should be a String.
    def self.subclass(subclass_name, &block)
      raise ArgumentError if subclass_name.nil?
      raise ArgumentError if Walrus::const_defined?(subclass_name)
      Walrus::const_set(subclass_name, Class.new(Grammar))
      Walrus::module_eval(subclass_name).new(&block)
    end
    
    def initialize(&block)
      @rules        = Hash.new { |hash, key| raise StandardError.new('no value for key "%s"' % key.to_s) }
      @productions  = Hash.new { |hash, key| raise StandardError.new('no value for key "%s"' % key.to_s) }
      self.instance_eval(&block) if block_given?
    end
    
    # Starts with starting_symbol.
    def parse(string)
      raise ArgumentError if string.nil?
      raise StandardError if @starting_symbol.nil?
      
      # TODO: may have to catch :ZeroWidthParseSuccess and others here as well
      begin
        @rules[@starting_symbol].parse(string)
      rescue ContinuationWrapperException => c  # a SymbolParslet wants to know what Grammar instance it belongs to
        c.continuation.call(self)
      end
    end
    
    # Defines a rule and stores it 
    # Expects an object that responds to the parse message, such as a Parslet or ParsletCombination.
    # As this is intended to work with Parsing Expression Grammars, each rule may only be defined once. Defining a rule more than once will raise an ArgumentError.
    def rule(symbol, parseable)
      raise ArgumentError if symbol.nil?
      raise ArgumentError if parseable.nil?
      raise ArgumentError if @rules.has_key?(symbol)
      
      
      # TODO: special case symbols?
      # if parseable.kind_of? Symbol
      #   @rules[symbol] = parseable.to_parseable
      # it it probably enough just to call to_parseable indiscriminately
      
      @rules[symbol] = parseable
    end
    
    # Expects a Node subclass.
    def production(symbol, first_node, *other_nodes)
    end
    
    # TODO: skip() method, defines that the following shall be consumed but not included in the output (useful for whitespace, for example)
    
    # Sets the starting symbol.
    def starting_symbol(symbol)
      @starting_symbol = symbol
    end
    
    # TODO: pretty print method?
    
  end # class Grammar
end # module Walrus




