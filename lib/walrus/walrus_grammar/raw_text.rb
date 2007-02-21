# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class RawText
      
      # If true, use unpack and pack to produce the compiled output.
      # If false, try to preserve readability in the compiled output (by using escape sequences).
      @@use_pack ||= false
      
      def self.use_pack=(value)
        @@use_pack = value
      end
      
      # Returns a string containing the compiled (Ruby) version of receiver. By using a format string that accepts as input an array of UTF-8 characters we avoid having to escape characters or sequences that would otherwise have a special meaning in Ruby.
      def compile
        if @@use_pack
          compiled = 'accumulate([ '
          @lexeme.unpack('U*').each { |number| compiled << '%d, ' % number } 
          compiled.sub!(/, \z/, ' ')   # trailing comma is harmless, but suppress it anyway for aesthetics
          compiled << "].pack('U*')) # RawText\n"
        else # try for human readable output
          "accumulate('" + @lexeme.to_source_string + "') # RawText\n"
        end
      end
      
    end
    
  end # class WalrusGrammar
end # Walrus

