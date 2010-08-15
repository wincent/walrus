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

class Symbol
  include Walrat::ParsletCombining

  # Returns a SymbolParslet based on the receiver.
  # Symbols can be used in Grammars when specifying rules and productions to
  # refer to other rules and productions that have not been defined yet.
  # They can also be used to allow self-references within rules and productions
  # (recursion); for example:
  #
  #   rule :thing & :thing.optional & :other_thing
  #
  # Basically these SymbolParslets allow deferred evaluation of a rule or
  # production (deferred until parsing takes place) rather than being evaluated
  # at the time a rule or production is defined.
  def to_parseable
    Walrat::SymbolParslet.new self
  end
end # class Symbol
