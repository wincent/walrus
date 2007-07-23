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

require 'walrus/parser.rb' # make sure that the class has been defined prior to extending it
require 'ostruct'

module Walrus
  class WalrusGrammar
    
    class ImportDirective
      
      # Returns an OpenStruct encapsulating information about the receiver for use by the compiler
      def compile(options = {})
        info = OpenStruct.new
        path = Pathname.new @class_name.lexeme.to_s
        
        if path.absolute?
          # it will work just fine as it is
          info.class_name   = path.basename.to_s.to_class_name
          info.require_line = "require '#{path.to_s}'"
        else
          dir, base       = path.split
          info.class_name = base.to_s.to_class_name
          if dir.to_s == '.'
            # desired template is in the same directory
            info.require_line = "require File.join(File.dirname(__FILE__), '#{base.to_s}').to_s"
          else
            # desired template is in a relative directory
            info.require_line = "require File.join(File.dirname(__FILE__), '#{dir.to_s}', '#{base.to_s}').to_s"
          end
        end  
        info
      end
      
    end # class ImportDirective
    
  end # class WalrusGrammar
end # Walrus

