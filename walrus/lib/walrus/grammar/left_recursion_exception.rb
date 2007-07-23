# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: left_recursion_exception.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus'

module Walrus
  class Grammar
    
    class LeftRecursionException < Exception
      
      attr_accessor :continuation
       
      def initialize(continuation = nil)
        super self.class.to_s
        @continuation = continuation
      end
      
    end # class LeftRecursionException
    
  end # class Grammar
end # module Walrus

