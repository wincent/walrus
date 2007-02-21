# Copyright 2007 Wincent Colaiuta
# $Id$

#require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class Comment
      
      def compile
        '# Comment:' + @lexeme.to_s + "\n"
      end
      
    end
    
  end # class WalrusGrammar
end # Walrus

