# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class RubyDirective
      
      # TODO: could make a #rubyecho method that did an "accumulate do" instead of instance_eval
      def compile(options = {})
        <<-ENDDOC
instance_eval do # Ruby directive
#{@content}
end
        ENDDOC
      end
      
    end # class RawDirective
    
  end # class WalrusGrammar
end # Walrus

