# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: string_result.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus'

module Walrus
  class Grammar
    class StringResult < String
      
      include Walrus::Grammar::LocationTracking
      
      def initialize(string = "")
        self.source_text = string
        super
      end
      
    end # class StringResult
  end # class Grammar
end # module Walrus
