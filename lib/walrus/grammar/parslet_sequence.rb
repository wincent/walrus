# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
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
        state                         = ParserState.new(string, options)
        last_caught                   = nil # keep track of the last kind of throw to be caught
        puts "about to start sequence, will try to parse '#{string}"
        @components.each do |parseable|
          puts "trying component #{parseable.to_s}, remainder is #{state.remainder}"
          catch :ProcessNextComponent do
            catch :NotPredicateSuccess do
              catch :AndPredicateSuccess do
                catch :ZeroWidthParseSuccess do
                  begin
                    parsed = parseable.memoizing_parse(state.remainder, state.options)
                    puts "parsed #{parsed.to_s}"
                    state.parsed(parsed)
                  rescue SkippedSubstringException => e
                    state.skipped(e)
                  rescue LeftRecursionException => e
                    puts "caught left recursion, current component is " + parseable.to_s
                    continuation  = nil
                    value         = callcc { |c| continuation = c }         
                    if value == continuation                    # first time that we're here
                      e.continuation = continuation             # pack continuation into exception
                      raise e                                   # and propagate
                    else
                      puts "alternative worked (parsed '#{value.to_s}')"
                      state.parsed(value)
                    end
                  rescue ParseError => e # failed, will try to skip; save original error in case skipping fails                                        
                    if options.has_key?(:skipping_override) : skipping_parslet = options[:skipping_override]
                    elsif options.has_key?(:skipping)       : skipping_parslet = options[:skipping]
                    else                                      skipping_parslet = nil
                    end
                    raise e if skipping_parslet.nil?        # no skipper defined, raise original error
                    begin
                      parsed = skipping_parslet.memoizing_parse(state.remainder, state.options) # guard against self references (possible infinite recursion) here?
                      state.skipped(parsed)
                      redo              # skipping succeeded, try to redo
                    rescue ParseError
                      raise e           # skipping didn't help either, raise original error
                    end
                  end
                  last_caught = nil
                  puts "done with #{parseable.to_s}, will try next component"
                  throw :ProcessNextComponent   # can't use "next" here because it would only break out of innermost "do" rather than continuing the iteration
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
        
        if state.results.respond_to? :empty? and state.results.empty? and last_caught
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

