# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that the class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class SlurpDirective
      
      # The slurp directive produces no meaningful output; but we leave a comment in the compiled template so that the location of the directive is visible in the source.
      def compile(options = {})
        "# Slurp directive\n"
      end
      
    end # class SlurpDirective
    
  end # class WalrusGrammar
end # Walrus

