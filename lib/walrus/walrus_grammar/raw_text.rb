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
      
      # Returns a string containing the compiled (Ruby) version of receiver.
      def compile
        if @@use_pack # avoid having to escape characters or sequences that would otherwise have a special meaning in Ruby.
          compiled = 'accumulate([ '
          @lexeme.to_s.unpack('U*').each { |number| compiled << '%d, ' % number } 
          compiled.sub!(/, \z/, ' ')   # trailing comma is harmless, but suppress it anyway for aesthetics
          compiled << "].pack('U*')) # RawText (packed)\n"
        else          # try for human readable output
          compiled  = []
          first     = true
          @lexeme.to_s.to_source_string.each do |line|
            newline = ''
            if line =~ /(\r\n|\r|\n)\z/       # check for literal newline at end of line
              line.chomp!                     # get rid of it
              newline = ' + ' + $~[0].dump    # include non-literal newline instead
            end
            
            if first
              compiled << "accumulate('%s'%s) # RawText\n" % [ line, newline ]
              first = false
            else
              compiled << "accumulate('%s'%s) # RawText (continued)\n" % [ line, newline ]
            end
            
          end
          compiled.join
        end
      end
      
    end
    
  end # class WalrusGrammar
end # Walrus

