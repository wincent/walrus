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
#
# $Id: silent_directive.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class SilentDirective
      
      def compile(options = {})
        
        if @expression.respond_to? :each
          expression = @expression
        else
          expression = [@expression]
        end
        
        # TODO: potentially include line, col and file name info in the comments generated by the compiler
        
        compiled  = ''
        first     = true
        expression.each do |expr| 
          if first
            compiled << "instance_eval { %s } # Silent directive\n" % expr.compile
            first = false
          else
            compiled << "instance_eval { %s } # Silent directive (continued)\n" % expr.compile
          end
        end
        compiled
        
      end
      
    end # class SilentDirective
    
  end # class WalrusGrammar
end # Walrus

