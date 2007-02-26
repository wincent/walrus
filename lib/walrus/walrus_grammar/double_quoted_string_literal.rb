# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class DoubleQuotedStringLiteral
      
      def compile(options = {})
        '"' + @lexeme.to_s + '"'
      end
      
    end # class DoubleQuotedStringLiteral
    
  end # class WalrusGrammar
end # Walrus

