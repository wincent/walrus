# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    class ParsletChoice < ParsletCombination
      
      attr_reader :hash
      
      # Either parameter may be a Parslet or a ParsletCombination.
      # Neither parmeter may be nil.
      def initialize(left, right, *others)
        raise ArgumentError if left.nil?
        raise ArgumentError if right.nil?
        @alternatives = [left, right] + others
        update_hash
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
      
      # First tries to parse the left option, falling back and trying the right option and then the any subsequent options in the others instance variable on failure. If no options successfully complete parsing then an ParseError is raised. Any zero-width parse successes thrown by alternative parsers will flow on to a higher level.
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        error = nil # for error reporting purposes will track which parseable gets farthest to the right before failing
        @alternatives.each do |parseable|
          begin
            return parseable.memoizing_parse(string, options)
          rescue ParseError => e
            if error.nil?   :   error = e
            else                error = e unless error.rightmost?(e)
            end
            next
          end
        end
        raise ParseError.new('no valid alternatives while parsing "%s"' % string, :rightmost => error)
      end
      
      def eql?(other)
        return false if not other.instance_of? ParsletChoice
        other_alternatives = other.alternatives
        return false if @alternatives.length != other_alternatives.length
        for i in 0..(@alternatives.length - 1)
          return false unless @alternatives[i].eql? other_alternatives[i]
        end
        true
      end
      
    protected
      
      # For determining equality.
      attr_reader :alternatives
      
    private
      
      def update_hash
        @hash = 30 # fixed offset to avoid unwanted collisions with similar classes
        @alternatives.each { |parseable| @hash += parseable.hash }
      end
      
      # Appends another Parslet (or ParsletCombination) to the receiver and returns the receiver.
      # Raises if parslet is nil.
      # Cannot use << as a method name because Ruby cannot parse it without the self, and self is not allowed as en explicit receiver for private messages.
      def append(next_parslet)
        raise ArgumentError if next_parslet.nil?
        @alternatives << next_parslet.to_parseable
        update_hash
        self
      end
      
    end # class ParsletChoice
  end # class Grammar
end # module Walrus
