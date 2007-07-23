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

# Additions to String class for Unicode support.
class String
  
  # Converts the receiver of the form "FooBar" to "foo_bar".
  # Concretely, the receiver is split into words, each word lowercased, and the words are joined together using a lower-case separator. "Words" are considered to be runs of characters starting with an initial capital letter (note that words may begin with consecutive capital letters), and numbers may mark the start or the end of a word.
  # Note that some information loss may be incurred; for example, "EOLToken" would be reduced to "eol_token".
  def to_require_name
    base = self.gsub(/([^A-Z_])([A-Z])/, '\1_\2')       # insert an underscore before any initial capital letters
    base.gsub!(/([A-Z])([A-Z])([^A-Z0-9_])/, '\1_\2\3') # consecutive capitals are words too, excluding any following capital that belongs to the next word
    base.gsub!(/([^0-9_])(\d)/, '\1_\2')                # numbers mark the start of a new word
    base.gsub!(/(\d)([^0-9_])/, '\1_\2')                # numbers also mark the end of a word
    base.downcase                                       # lowercase everything
  end
  
  # Converts the receiver of the form "foo_bar" to "FooBar".
  # Specifically, the receiver is split into pieces delimited by underscores, each component is then converted to captial case (the first letter is capitalized and the remaining letters are lowercased) and finally the components are joined.
  # Note that this method cannot recover information lost during a conversion using the require_name_from_classname method; for example, "EOL", when converted to "token", would be transformed back to "EolToken". Likewise, "Foo__bar" would be reduced to "foo__bar" and then in the reverse conversion would become "FooBar".
  def to_class_name
    self.split('_').collect { |component| component.capitalize}.join
  end
  
  # Returns a copy of the receiver with occurrences of \ replaced with \\, and occurrences of ' replaced with \'
  def to_source_string
    gsub(/[\\']/, '\\\\\&')
  end
  
end # class String
