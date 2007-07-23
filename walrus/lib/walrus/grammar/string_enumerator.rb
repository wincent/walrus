# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: string_enumerator.rb 154 2007-03-26 19:03:21Z wincent $

require 'strscan'
require 'walrus'

module Walrus
  class Grammar
    
    # Unicode-aware (UTF-8) string enumerator.
    # For Unicode support $KCODE must be set to 'U' (UTF-8).
    class StringEnumerator
      
      # Returns the char most recently scanned before the last "next" call, or nil if nothing previously scanned.
      attr_reader :last
      
      def initialize(string)
        raise ArgumentError if string.nil?
        @scanner  = StringScanner.new(string)
        @current  = nil
        @last     = nil
      end
      
      # This method will only work as expected if $KCODE is set to 'U' (UTF-8).
      def next
        @last     = @current
        @current  = @scanner.scan(/./m) # must use multiline mode or "." won't match newlines
      end
      
      # Take a peek at the next character without actually consuming it. Returns nil if there is no next character.
      # TODO: consider deleting this method as it's not currently used.
      def peek
        if char = self.next : @scanner.unscan; end
        char
      end
      
    end # class StringEnumerator
    
  end # class Grammar
end # module Walrus
