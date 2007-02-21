# Copyright 2007 Wincent Colaiuta
# $Id$

#require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class EscapeSequence
      
      def compile
        "accumulate(%s) \# EscapeSequence\n" % @lexeme.to_s.dump
      end
      
    end
    
  end # class WalrusGrammar
end # Walrus

