# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    attr_accessor :memoizing
    attr_reader   :rules
    attr_reader   :skipping_overrides
    
    # Creates a Grammar subclass named according to subclass_name and instantiates an instance of the new class, returning it after evaluating the optional block in the context of the newly created instance. The advantage of working inside a new subclass is that any constants defined in the new grammar will be in a separate namespace.
    # The subclass_name parameter should be a String.
    def self.subclass(subclass_name, &block)
      raise ArgumentError if subclass_name.nil?
      raise ArgumentError if Walrus::const_defined?(subclass_name)
      Walrus::const_set(subclass_name, Class.new(Grammar))
      subclass = Walrus::module_eval(subclass_name)
      begin
        subclass.new(&block)
      rescue ContinuationWrapperException => c # a Symbol in a production rule wants to know what namespace its being used in
        c.continuation.call(subclass)
      end
    end
    
    def initialize(&block)
      @rules              = Hash.new { |hash, key| raise StandardError.new('no rule for key "%s"' % key.to_s) }
      @productions        = Hash.new { |hash, key| raise StandardError.new('no production for key "%s"' % key.to_s) }
      @skipping_overrides = Hash.new { |hash, key| raise StandardError.new('no skipping override for key "%s"' % key.to_s) }
      @memoizing          = true
      self.instance_eval(&block) if block_given?
    end
    
    # TODO: consider making grammars copiable (could be used in threaded context then)
    #def initialize_copy(from); end
    #def clone; end
    #def dupe; end
    
    # Starts with starting_symbol.
    def parse(string, options = {})
      raise ArgumentError if string.nil?
      raise StandardError if @starting_symbol.nil?
      options[:grammar]       = self
      options[:rule_name]     = @starting_symbol
      options[:skipping]      = @skipping
      options[:line_start]    = 0 # "richer" information (more human-friendly) than that provided in "location"
      options[:column_start]  = 0 # "richer" information (more human-friendly) than that provided in "location"
      options[:memoizer]      = MemoizingCache.new if @memoizing
      @starting_symbol.to_parseable.memoizing_parse(string, options)
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
    # Example; using the "build" method to dynamically define an "AssigmentExpression" class with superclass "Expression" and assign the created class as the AST production class for the rule "assignment_expression":
    #
    #   production :assignment_expression.build(:expression, :target, :value)
    #
    def production(rule_name, class_symbol = nil)
      raise ArgumentError if rule_name.nil?
      raise ArgumentError if @productions.has_key?(rule_name)
      raise ArgumentError unless @rules.has_key?(rule_name)
      class_symbol = rule_name if class_symbol.nil?
      @productions[rule_name] = class_symbol
    end
    
    def wrap(result, rule_name)
      if @productions.has_key?(rule_name.to_sym)    # figure out arity of "initialize" method and wrap results in AST node
        node_class  = self.class.const_get(@productions[rule_name.to_sym].to_s.to_class_name)
        param_count = node_class.instance_method(:initialize).arity
        raise if param_count < 1
        
        # dynamically build up a message send
        if param_count == 1 : params        = 'result'
        else                  params        = 'result[0]'
        end
        for i in 1..(param_count - 1)
          params << ", result[#{i.to_s}]"
        end
        
        node                = node_class.class_eval('new(%s)' % params)
        node.start          = result.start        # propagate the start information
        node.end            = result.end          # and the end information
        node.source_text    = result.source_text  # and the original source text
        node
        
      else
        result
      end
    end
    
    # Sets the starting symbol.
    # symbol must refer to a rule.
    def starting_symbol(symbol)
      @starting_symbol = symbol
    end
    
    # Sets the default parslet that is used for skipping inter-token whitespace, and can be used to override the default on a rule-by-rule basis.
    # This allows for simpler grammars which do not need to explicitly put optional whitespace parslets (or any other kind of parslet) between elements.
    #
    # There are two modes of operation for this method. In the first mode (when only one parameter is passed) the rule_or_parslet parameter is used to define the default parslet for inter-token skipping. rule_or_parslet must refer to a rule which itself is a Parslet or ParsletCombination and which is responsible for skipping. Note that the ability to pass an arbitrary parslet means that the notion of what consitutes the "whitespace" that should be skipped is completely flexible. Raises if a default skipping parslet has already been set.
    #
    # In the second mode of operation (when two parameters are passed) the rule_or_parslet parameter is interpreted to be the rule to which an override should be applied, where the parslet parameter specifies the parslet to be used in this case. If nil is explicitly passed then this overrides the default parslet; no parslet will be used for the purposes of inter-token skipping. Raises if an override has already been set for the named rule.
    #
    # The inter-token parslet is passed inside the "options" hash when invoking the "parse" methods. Any parser which fails will retry after giving this inter-token parslet a chance to consume and discard intervening whitespace.
    # The initial, conservative implementation only performs this fallback skipping for ParsletSequence and ParsletRepetition combinations.
    #
    # Raises if rule_or_parslet is nil.
    def skipping(rule_or_parslet, parslet = NoParameterMarker.instance)
      raise ArgumentError if rule_or_parslet.nil?
      if parslet == NoParameterMarker.instance  # first mode of operation: set default parslet
        raise if @skipping                      # should not set a default skipping parslet twice
        @skipping = rule_or_parslet
      else                                      # second mode of operation: override default case
        raise ArgumentError if @skipping_overrides.has_key?(rule_or_parslet)
        raise ArgumentError unless @rules.has_key?(rule_or_parslet)
        @skipping_overrides[rule_or_parslet] = parslet
      end
    end
    
    # TODO: pretty print method?
    
  end # class Grammar
end # module Walrus




