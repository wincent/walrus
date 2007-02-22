# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    class RegexpParslet < Parslet
      
      attr_reader :hash
      
      def initialize(regexp)
        raise ArgumentError if regexp.nil?
        super()
        self.expected_regexp = /\A#{regexp}/ # for efficiency, anchor all regexps to the start of the string
      end
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        @column_offset, @line_offset = [0, 0] # reset
        if (string =~ @expected_regexp)
          wrapper = MatchDataWrapper.new($~)
          match   = $~[0]
          
          # count number of newlines in match
          @line_offset  = match.scan(/\r\n|\r|\n/).length
          
          # count characters on last line
          last_newline = match.rindex(/\r|\n/)
          if last_newline :   @column_offset = match.length - last_newline - 1
          else                @column_offset = match.length
          end
          
          wrapper
        else
          raise ParseError.new('non-matching characters "%s" while parsing regular expression "%s"' % [string, @expected_regexp.inspect])
        end
      end
      
      def eql?(other)
        other.instance_of? RegexpParslet and other.expected_regexp == @expected_regexp
      end
      
      def inspect
        '#<%s:0x%x @expected_regexp=%s>' % [self.class.to_s, self.object_id, @expected_regexp.inspect]
      end
      
    protected
      
      # For equality comparisons.
      attr_reader :expected_regexp
      
    private
      
      def expected_regexp=(regexp)
        @expected_regexp = ( regexp.clone rescue regexp )
        update_hash
      end
      
      def update_hash
        @hash = @expected_regexp.hash + 15 # fixed offset to avoid collisions with @parseable objects
      end
      
    end # class RegexpParslet
    
  end # class Grammar
end # module Walrus

