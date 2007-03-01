# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class SetDirective
      
      def compile(options = {})
        "set_value(%s, instance_eval { %s }) # Set directive \n" % [ @placeholder.to_s.dump, @expression.compile ]
      end
      
    end # class SetDirective
    
  end # class WalrusGrammar
end # Walrus

