# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    autoload(:ParseError, 'walrus/grammar/parse_error')
    
    require 'walrus/grammar/parslet_combination'
    class ParsletChoice < ParsletCombination
      
      # Either parameter may be a Parslet or a ParsletCombination.
      # Neither parmeter may be nil.
      def initialize(left, right, *others)
        raise ArgumentError if left.nil?
        raise ArgumentError if right.nil?
        @left   = left
        @right  = right
        @others = others
      end
      
      # Override so that alternatives are appended to an existing sequence:
      # Consider the following example:
      #     A | B
      # This constitutes a single choice:
      #     (A | B)
      # If we then make this a three-element sequence:
      #     A | B | C
      # We are effectively creating an nested sequence containing the original sequence and an additional element:
      #     ((A | B) | C)
      # Although such a nested sequence is correctly parsed it is not as architecturally clean as a single sequence without nesting:
      #     (A | B | C)
      # This method allows us to use the architecturally cleaner format.
      #
      def |(next_parslet)
        append(next_parslet)
      end
      
      # First tries to parse the left option, falling back and trying the right option and then the any subsequent options in the others instance variable on failure. If no options successfully complete parsing then an ParseError is raised. Any zero-width parse successes throw by alternative parsers will flow on to a higher level.
      def parse(string)
        raise ArgumentError if string.nil?
        alternatives = [@left, @right] + @others
        alternatives.each do |parseable|
        begin
          return parseable.parse(string)
        rescue ParseError
          next
        end
        end
        raise ParseError.new('no valid alternatives while parsing "%s"' % string)
      end
    
    private
      
      # Appends another Parslet (or ParsletCombination) to the receiver and returns the receiver.
      # Raises if parslet is nil.
      # Cannot use << as a method name because Ruby cannot parse it without the self, and self is not allowed as en explicit receiver for private messages.
      def append(next_parslet)
        raise ArgumentError if next_parslet.nil?
        @others << next_parslet.to_parseable
        self
      end
      
    end # class ParsletChoice
  end # class Grammar
end # module Walrus
