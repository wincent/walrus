# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class RubyDirective
      
      # TODO: could make a #rubyecho method that did an "accumulate do" instead of instance_eval
      def compile(options = {})
        # possible problem here is that the compiler will indent each line for us, possibly breaking here docs etc
        # seeing as it is going to be indented anyway, I add some additional indenting here for pretty printing purposes
        compiled = "instance_eval do # Ruby directive\n"
        @content.to_s.each { |line| compiled << '  ' + line }
        compiled << "end\n"
      end
      
    end # class RawDirective
    
  end # class WalrusGrammar
end # Walrus

