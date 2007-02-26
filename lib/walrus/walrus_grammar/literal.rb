# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class Literal
      
      def compile(options = {})
        @lexeme.source_text
      end
      
    end # class Literal
    
  end # class WalrusGrammar
end # Walrus

