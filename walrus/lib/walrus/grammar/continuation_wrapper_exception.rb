# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: continuation_wrapper_exception.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus'

module Walrus
  class Grammar
    
    class ContinuationWrapperException < Exception
      
      attr_reader :continuation
      
      def initialize(continuation)
        raise ArgumentError if continuation.nil?
        super self.class.to_s
        @continuation = continuation
      end
      
    end # class ContinuationWrapperException
    
  end # class Grammar
end # module Walrus

