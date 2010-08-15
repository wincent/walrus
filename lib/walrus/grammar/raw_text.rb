# Copyright 2007-2010 Wincent Colaiuta
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

require 'walrus/grammar.rb'
require 'walrus/additions/string'

module Walrus
  class Grammar
    class RawText < Walrat::Node
      # Returns a string containing the compiled (Ruby) version of receiver.
      # If options[:slurping] is true, instructs the receiver to strip the
      # leading carriage return/line feed from the @lexeme prior to emitting
      # the compiled output.
      def compile options = {}
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
  end # class Grammar
end # Walrus
