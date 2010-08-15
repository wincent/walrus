# Copyright 2007-2010 Wincent Colaiuta
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

require 'walrat'

module Walrat
  class ParseError < Exception
    include Walrat::LocationTracking

    # Takes an optional hash (for packing extra info into exception).
    # position in string (irrespective of line number, column number)
    # line number, column number
    # filename
    def initialize message, info = {}
      super message
      self.line_start     = info[:line_start]
      self.column_start   = info[:column_start]
      self.line_end       = info[:line_end]
      self.column_end     = info[:column_end]
    end

    def inspect
      # TODO: also return filename if available
      '#<%s: %s @line_end=%d, @column_end=%d>' %
        [ self.class.to_s, self.to_s, self.line_end, self.column_end ]
    end
  end # class ParseError
end # module Walrat

