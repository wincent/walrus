# Copyright 2007 Wincent Colaiuta
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

