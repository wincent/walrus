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

# multibyte-friendly implementations of String#index and String#rindex
require 'jindex'

# Additions to String class for Unicode support.
# Parslet combining methods.
# Convenience methods (to_parseable).
# Conversion utility methods.
class String
  # Returns an array of Unicode characters.
  def chars
    scan /./m
  end

  alias old_range []

  # multi-byte friendly [] implementation
  def [](range, other = Walrat::NoParameterMarker.instance)
    if other == Walrat::NoParameterMarker.instance
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
    Walrat::StringEnumerator.new self
  end

  # Rationale: it's ok to add "&" and "|" methods to string because they don't
  # exist yet (they're not overrides).
  include Walrat::ParsletCombining

  # Returns a StringParslet based on the receiver
  def to_parseable
    Walrat::StringParslet.new self
  end

  # Converts the receiver of the form "foo_bar" to "FooBar". Specifically, the
  # receiver is split into pieces delimited by underscores, each component is
  # then converted to captial case (the first letter is capitalized and the
  # remaining letters are lowercased) and finally the components are joined.
  def to_class_name
    self.split('_').collect { |component| component.capitalize}.join
  end

  # Converts the receiver of the form "foo_bar" to "FooBar". Specifically, the
  # receiver is split into pieces delimited by underscores, each component is
  # then converted to captial case (the first letter is capitalized and the
  # remaining letters are lowercased) and finally the components are joined.
  # Note that this method cannot recover information lost during a conversion
  # using the to_require_name method; for example, "EOLToken", when converted
  # to "eol_token", would be transformed back to "EolToken". Likewise,
  # "Foo__bar" would be reduced to "foo__bar" and then in the reverse
  # conversion would become "FooBar".
  def to_class_name
    self.split('_').collect { |component| component.capitalize}.join
  end

end # class String
