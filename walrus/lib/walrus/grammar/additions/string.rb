# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: string.rb 154 2007-03-26 19:03:21Z wincent $

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
