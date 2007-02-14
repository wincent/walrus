# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    autoload(:MatchDataWrapper, 'walrus/grammar/match_data_wrapper')
    autoload(:ParseError,       'walrus/grammar/parse_error')
    
    require 'walrus/grammar/parslet'
    class RegexpParslet < Parslet
      
      attr_reader :expected_regexp
      
      def initialize(regexp)
        raise ArgumentError if regexp.nil?
        self.expected_regexp = /\A#{regexp}/ # for efficiency, anchor all regexps to the start of the string
      end
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        if (string =~ @expected_regexp)
          MatchDataWrapper.new($~)
        else
          raise ParseError.new('non-matching characters "%s" while parsing regular expression "%s"' % [string, @expected_regexp.inspect])
        end
      end
      
    private
      
      def expected_regexp=(regexp)
        @expected_regexp = ( regexp.clone rescue regexp )
      end
      
    end # class RegexpParslet
    
  end # class Grammar
end # module Walrus

