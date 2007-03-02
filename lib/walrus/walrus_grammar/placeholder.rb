# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class Placeholder
      
      def compile(options = {})
        # basic implementation to begin with (no parameters)
        "lookup_and_accumulate_placeholder(#{@name.to_s.to_sym.inspect})\n"
        
        # special case when placeholder is not used as part of literal text; return the value rather than accumulating
        
      end
      
    end # class Placeholder
    
  end # class WalrusGrammar
end # Walrus

