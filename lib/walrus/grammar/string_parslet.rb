# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    class StringParslet < Parslet
      
      attr_reader :hash
      
      def initialize(string)
        raise ArgumentError if string.nil?
        super()
        self.expected_string = string
      end
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        @column_offset, @line_offset = [0, 0] # reset
        chars = StringEnumerator.new(string)
        parsed = ''
        expected_string.each_char do |expected_char|
          actual_char = chars.next
          if actual_char.nil?
            raise ParseError.new('unexpected end-of-string (expected "%s") while parsing "%s"' % [ expected_char, expected_string ])
          elsif actual_char != expected_char
            raise ParseError.new('unexpected character "%s" (expected "%s") while parsing "%s"' % [ actual_char, expected_char, expected_string])
          else
            if actual_char == "\r" or (actual_char == "\n" and chars.last != "\r")  # catches Mac, Windows and UNIX end-of-line markers
              @column_offset  =   0
              @line_offset    +=  1
            elsif actual_char != "\n" # \n is ignored if it is preceded by an \r (already counted above)
              @column_offset  +=  1   # everything else gets counted
            end
            parsed << actual_char
          end
        end
        parsed
      end
      
      def eql?(other)
        other.instance_of? StringParslet and other.expected_string == @expected_string
      end
      
    protected
      
      # For equality comparisons.
      attr_reader :expected_string
      
    private
      
      def expected_string=(string)
        @expected_string = ( string.clone rescue string )
        update_hash
      end
      
      def update_hash
        @hash = @expected_string.hash + 20 # fixed offset to avoid collisions with @parseable objects
      end
      
    end # class StringParslet
    
  end # class Grammar
end # module Walrus

