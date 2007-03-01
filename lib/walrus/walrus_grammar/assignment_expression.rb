# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class AssignmentExpression
      
      def compile(options = {})
        
        @lvalue.source_text + '=' + @expression.source_text
        
        # or simply...
        #self.source_text
        
      end
      
    end # class AssignmentExpression
    
  end # class WalrusGrammar
end # Walrus

