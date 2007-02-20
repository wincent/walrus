# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class RawText
      
      # Returns a string containing the compiled (Ruby) version of receiver. By using a format string that accepts as input an array of UTF-8 characters we avoid having to escape characters or sequences that would otherwise have a special meaning in Ruby.
      def compile
        compiled = 'accumulate([ '
        @lexeme.unpack('U*').each { |number| compiled << '%d, ' % number } 
        compiled.sub!(/, \z/, ' ')   # trailing comma is harmless, but suppress it anyway for aesthetics
        compiled << "].pack('U*'))\n"
      end
      
    end
    
  end # class WalrusGrammar
end # Walrus

