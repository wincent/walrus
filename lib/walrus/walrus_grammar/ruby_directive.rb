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
