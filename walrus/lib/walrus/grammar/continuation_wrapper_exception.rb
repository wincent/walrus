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

