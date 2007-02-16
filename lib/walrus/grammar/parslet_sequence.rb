# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    autoload(:ParserState, 'walrus/grammar/parser_state')
    autoload(:SkippedSubstringException, 'walrus/grammar/skipped_substring_exception')
    
    require 'walrus/grammar/parslet_combination'
    class ParsletSequence < ParsletCombination
      
      attr_reader :hash
      
      # first and second may not be nil.
      def initialize(first, second, *others)
        raise ArgumentError if first.nil?
        raise ArgumentError if second.nil?
        @components = [first, second] + others
        update_hash
      end
      
      # Override so that sequences are appended to an existing sequence:
      # Consider the following example:
      #     A & B
      # This constitutes a single sequence:
      #     (A & B)
      # If we then make this a three-element sequence:
      #     A & B & C
      # We are effectively creating an nested sequence containing the original sequence and an additional element:
      #     ((A & B) & C)
      # Although such a nested sequence is correctly parsed it produces unwanted nesting in the results because instead of returning a one-dimensional an array of results:
      #     [a, b, c]
      # It returns a nested array:
      #     [[a, b], c]
      # The solution to this unwanted nesting is to allowing appending to an existing sequence by using the private "append" method.
      # This ensures that:
      #     A & B & C
      # Translates to a single sequence:
      #     (A & B & C)
      # And a single, uni-dimensional results array:
      #     [a, b, c]
      #
      def &(next_parslet)
        append(next_parslet)
      end
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        state             = ParserState.new(string)
        last_caught       = nil # keep track of the last kind of throw to be caught
        augmented_options = options.clone
        augmented_options[:location] = 0 unless augmented_options.has_key? :location
        @components.each do |parseable|
          catch :ProcessNextComponent do
            catch :NotPredicateSuccess do
              catch :AndPredicateSuccess do
                catch :ZeroWidthParseSuccess do
                  begin
                    starting_location = state.length  # remember current location within current ParserState instance
                    parsed = parseable.memoizing_parse(state.remainder, augmented_options)
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
                        raise e # skipping didn't help either, raise original error
                      end
                      state.skipped(parsed)
                      state.skipped(parsed.omitted.to_s)
                      augmented_options[:location] = augmented_options[:location] + (state.length - starting_location)
                      redo # skipping succeeded, try to redo
                    end
                    raise e # no skipper defined, raise original error
                  end
                  last_caught = nil
                  throw :ProcessNextComponent # can't use "next" here because it will only break out of innermost "do"
                end
                last_caught = :ZeroWidthParseSuccess
                throw :ProcessNextComponent
              end
              last_caught = :AndPredicateSuccess
              throw :ProcessNextComponent
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
        return false if not other.instance_of? ParsletSequence
        other_components = other.components
        return false if @components.length != other_components.length
        for i in 0..(@components.length - 1)
          return false unless @components[i].eql? other_components[i]
        end
        true
      end
      
    protected
      
      # For determining equality.
      attr_reader :components
      
    private
      
      def hash_offset
        40
      end
      
      def update_hash
        @hash = hash_offset # fixed offset to avoid unwanted collisions with similar classes
        @components.each { |parseable| @hash += parseable.hash }
      end
      
      # Appends another Parslet, ParsletCombination or Predicate to the receiver and returns the receiver.
      # Raises if next_parslet is nil.
      # Cannot use << as a method name because Ruby cannot parse it without the self, and self is not allowed as en explicit receiver for private messages.
      def append(next_parslet)
        raise ArgumentError if next_parslet.nil?
        @components << next_parslet.to_parseable
        update_hash
        self
      end
      
    end # class ParsletSequence
  end # class Grammar
end # module Walrus

