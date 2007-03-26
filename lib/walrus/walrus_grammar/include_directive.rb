# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that the class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class IncludeDirective
      
      def compile(options = {})
        inner, outer = options[:compiler_instance].compile_subtree(subtree)
        inner = [] if inner.nil?
        inner.unshift "\# Include (start): #{file_name.to_s}:\n"
        [inner, outer]
      end
      
    end # class IncludeDirective
    
  end # class WalrusGrammar
end # Walrus

