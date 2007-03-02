# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that the class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class SuperDirective
      
      def compile(options = {})
        
        # basic case, no explicit parameters
        'super # Super directive'
        
      end
      
    end # class SuperDirective
    
  end # class WalrusGrammar
end # Walrus

