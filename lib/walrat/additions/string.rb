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

# Additions to String class for Unicode support.
# Parslet combining methods.
# Convenience methods (to_parseable).
# Conversion utility methods.
class String
  alias old_range []

  def jlength
    chars.to_a.length
  end

  # NOTE: this is a totally Walrat-specific implementation that is
  # unlikely to be of use anywhere else. It is used in only 1 place
  # in the codebase, and works around the fact that the MatchData
  # made available by the index method gets clobbered by the
  # "chars.to_a" call. The same thing happens for alternative
  # methods of counting the chars, such as using jlength or a manual
  # scan.
  #
  # One workaround is for the caller to re-perform the index call just
  # to get the MatchData again, but that is inefficient. So here we
  # just do the addition before returning the result to the caller.
  def jindex_plus_length arg
    if i = index(arg)
      $~[0].length + unpack('C*')[0...i].pack('C*').chars.to_a.length
    end
  end

  # Unlike the normal rindex method, the MatchData in $~ set by the inner
  # rindex call gets clobbered (by the "chars.to_a" call) and is not visible to
  # the caller of this method.
  def jrindex arg, offset = Walrat::NoParameterMarker.instance
    if offset == Walrat::NoParameterMarker.instance
      i = rindex arg
    else
      i = rindex arg, offset
    end
    i ? unpack('C*')[0...i].pack('C*').chars.to_a.length : nil
  end

  # multi-byte friendly [] implementation
  def [](range, other = Walrat::NoParameterMarker.instance)
    if other == Walrat::NoParameterMarker.instance
      if range.kind_of? Range
        chars.to_a[range].join
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
end # class String
