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
    
    # I don't really like using Exceptions for non-error situations, but it seems that using throw/catch here would not be adequate (not possible to embed information in the thrown symbol).
    class SkippedSubstringException < Exception
      
      include Walrus::Grammar::LocationTracking
      
      def initialize(substring, info = {})
        super substring
        
        # TODO: this code is just like the code in ParseError. could save repeating it by setting up inheritance
        # but would need to pay careful attention to the ordering of my rescue blocks
        # and also change many instances of "kind_of" in my specs to "instance_of "
        # alternatively, could look at using a mix-in
        self.line_start     = info[:line_start]
        self.column_start   = info[:column_start]
        self.line_end       = info[:line_end]
        self.column_end     = info[:column_end]
      end
      
    end # class SkippedSubstringException
    
  end # class Grammar
end # module Walrus

