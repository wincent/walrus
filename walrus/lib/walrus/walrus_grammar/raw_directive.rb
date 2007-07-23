# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: raw_directive.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class RawDirective
      
      # Returns a string containing the compiled (Ruby) version of receiver.
      def compile(options = {})
        compiled  = []
        first     = true
        @content.to_s.to_source_string.each do |line|
          newline = ''
          if line =~ /(\r\n|\r|\n)\z/       # check for literal newline at end of line
            line.chomp!                     # get rid of it
            newline = ' + ' + $~[0].dump    # include non-literal newline instead
          end
          
          if first
            compiled << "accumulate('%s'%s) # RawDirective\n" % [ line, newline ]
            first = false
          else
            compiled << "accumulate('%s'%s) # RawDirective (continued)\n" % [ line, newline ]
          end
          
        end
        compiled.join
      end
      
    end # class RawDirective
    
  end # class WalrusGrammar
end # Walrus

