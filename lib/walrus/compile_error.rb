# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    class CompileError < Exception
      
      # take an optional hash (for packing extra info into exception?)
      # position in AST/source file
      # line number, column number
      # filename
      def initialize(message, info = {})
        super message
      end
      
    end # class CompileError
    
  end # class Grammar
end # module Walrus

