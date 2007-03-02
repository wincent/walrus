# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class Placeholder
      
      def compile(options = {})
        # basic implementation to begin with (no parameters)
      end
      
    end # class Placeholder
    
  end # class WalrusGrammar
end # Walrus

