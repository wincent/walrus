# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: import_directive.rb 154 2007-03-26 19:03:21Z wincent $

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

