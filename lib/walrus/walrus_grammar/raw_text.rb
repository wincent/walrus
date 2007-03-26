# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class RawText
      
      # Returns a string containing the compiled (Ruby) version of receiver.
      # If options[:slurping] is true, instructs the receiver to strip the leading carriage return/line feed from the @lexeme prior to emitting the compiled output.
      def compile(options = {})
        lexeme = options[:slurping] ? @lexeme.to_s.sub(/\A(\r\n|\r|\n)/, '') : @lexeme.to_s
        
        compiled  = ''
        first     = true
        lexeme.to_source_string.each do |line|
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
        compiled
      end
      
    end # class RawText
    
  end # class WalrusGrammar
end # Walrus

