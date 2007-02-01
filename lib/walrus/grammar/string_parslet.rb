# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/grammar/additions/string'

module Walrus
  class Grammar
    
    autoload(:ParseError, 'walrus/grammar/parse_error')
    
    require 'walrus/grammar/parslet'
    class StringParslet < Parslet
      
      attr_reader :expected_string
      
      def initialize(string)
        raise ArgumentError if string.nil?
        self.expected_string = string
      end
      
      def parse(string)
        raise ArgumentError if string.nil?
        chars = StringEnumerator.new(string)
        parsed = ''
        expected_string.each_char do |expected_char|
          actual_char = chars.next
          if actual_char.nil?
            raise ParseError.new('unexpected end-of-string (expected "%s") while parsing "%s"' % [ expected_char, expected_string ])
          elsif actual_char != expected_char
            raise ParseError.new('unexpected character "%s" (expected "%s") while parsing "%s"' % [ actual_char, expected_char, expected_string])
          else
            parsed << actual_char
          end
        end
        parsed
      end
      
    private
      
      def expected_string=(string)
        @expected_string = ( string.clone rescue string )
      end
      
    end # class StringParslet
    
  end # class Grammar
end # module Walrus

