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

require 'walrus'

require 'jindex' # multibyte-friendly implementations of String#index and String#rindex

# Additions to String class for Unicode support.
class String
  
  # Returns an array of Unicode characters.
  def chars
    scan(/./m)
  end
  
  alias old_range []
  
  # multi-byte friendly [] implementation
  def [](range, other = Walrus::NoParameterMarker.instance)
    if other == Walrus::NoParameterMarker.instance
      if range.kind_of? Range
        chars[range].join
      else
        old_range range
      end
    else
      old_range range, other
    end
  end
  
  # Returns a character-level enumerator for the receiver.
  def enumerator
    Walrus::Grammar::StringEnumerator.new(self)
  end
  
end # class String

class String
  
  include Walrus::Grammar::ParsletCombining   # Rationale: it's ok to add "&" and "|" methods to string because they don't exist yet (they're not overrides).
  
  # Returns a StringParslet based on the receiver
  def to_parseable
    Walrus::Grammar::StringParslet.new(self)
  end
  
end # class String