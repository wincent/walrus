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
  # I don't really like using Exceptions for non-error situations, but it seems
  # that using throw/catch here would not be adequate (not possible to embed
  # information in the thrown symbol).
  class SkippedSubstringException < Exception
    include Walrat::LocationTracking

    def initialize substring, info = {}
      super substring

      # TODO: this code is just like the code in ParseError. could save
      # repeating it by setting up inheritance but would need to pay careful
      # attention to the ordering of my rescue blocks and also change many
      # instances of "kind_of" in my specs to "instance_of "
      # alternatively, could look at using a mix-in
      self.line_start     = info[:line_start]
      self.column_start   = info[:column_start]
      self.line_end       = info[:line_end]
      self.column_end     = info[:column_end]
    end
  end # class SkippedSubstringException
end # module Walrat
