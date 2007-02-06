# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/additions/string'

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
      begin
        Walrus::module_eval(subclass_name).new(&block)
      rescue ContinuationWrapperException => c # a Symbol in a production rule wants to know what namespace its being used in
        c.continuation.call(self)
      end
    end
    
    def initialize(&block)
      @rules        = Hash.new { |hash, key| raise StandardError.new('no value for key "%s"' % key.to_s) }
      @productions  = Hash.new { |hash, key| raise StandardError.new('no value for key "%s"' % key.to_s) }
      self.instance_eval(&block) if block_given?
    end
    
    # Starts with starting_symbol.
    def parse(string, options = {})
      raise ArgumentError if string.nil?
      raise StandardError if @starting_symbol.nil?
      
      # TODO: may have to catch :ZeroWidthParseSuccess and others here as well
      # 1. get the parse results
      # 2. call grammar.wrap(results) and return them?
      # in practice only symbol parslets will do the wrap lookup, I think...
      # ironically, this hash-passing makes my ContinuationWrapper trick unnecessary (in the case of symbol parslets; may still need them in other cases... eg. when you send a ^ message to a Symbol instance when defining a production)
      options[:grammar] = self
      options[:rule_name] = @starting_symbol
      @rules[@starting_symbol].parse(string, options)
    end
    
    # Defines a rule and stores it 
    # Expects an object that responds to the parse message, such as a Parslet or ParsletCombination.
    # As this is intended to work with Parsing Expression Grammars, each rule may only be defined once. Defining a rule more than once will raise an ArgumentError.
    def rule(symbol, parseable)
      raise ArgumentError if symbol.nil?
      raise ArgumentError if parseable.nil?
      raise ArgumentError if @rules.has_key?(symbol)
      @rules[symbol] = parseable
    end
    
    # Dynamically creates a Node subclass inside the namespace of the current grammar. If parent_class is nil, Node is assumed.
    # new_class_name must not be nil.
    def node(new_class_name, parent_class = nil, *attributes)
      raise ArgumentError if new_class_name.nil?
      parent_class = :Node if parent_class.nil?
      new_class_name = new_class_name.to_s.to_class_name # camel-case
      if parent_class.nil?
        Node.subclass(new_class_name, self.class, *attributes)
      else
        # convert parent_class to string, then camel case, then back to Symbol, then lookup the constant
        self.class.const_get(parent_class.to_s.to_class_name.to_s).subclass(new_class_name, self.class, *attributes)
      end
    end
    
    # Specifies the Node subclass that will be used to encapsulate results for the rule identified by the symbol, rule_name.
    # class_symbol, if present, will be converted to camel-case and explicitly names the class to be used. If class_symbol is not specified then a camel-cased version of the rule_name itself is used.
    # rule_name must not be nil.
    #
    # Example; specifying that the results of rule "string_literal" should be encapsulated in a "StringLiteral" instance:
    #
    #   production :string_literal
    #
    # Example; specifying that the results of the rule "numeric_literal" should be encapsulated into a "RawToken" instance:
    #
    #   production :numeric_literal, :raw_token
    #
    # Example; using the "^" shorthand psuedo-operator to dynamically define an "AssigmentExpression" class with superclass "Expression" and assign the created class as the AST production class for the rule "assignment_expression":
    #
    #   production :assignment_expression ^ :expression, :target, :value
    #
    def production(rule_name, class_symbol = nil)
      raise ArgumentError if rule_name.nil?
      raise ArgumentError if @productions.has_key?(rule_name)
      raise ArgumentError unless @rules.has_key?(rule_name)
      class_symbol = rule_name if class_symbol.nil?
      @productions[rule_name] = class_symbol
    end
    
    def wrap(result, rule_name)
      if @productions.has_key?(rule_name.to_s)
        # figure out arity wrap in AST node
      else
        result
      end
    end
    
    # Sets the starting symbol.
    def starting_symbol(symbol)
      @starting_symbol = symbol
    end
    
    # TODO: pretty print method?
    
  end # class Grammar
end # module Walrus




