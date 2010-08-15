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
  # Simple wrapper for MatchData objects that implements length, to_s and
  # to_str methods.
  #
  # By implementing to_str, MatchDataWrappers can be directly compared with
  # Strings using the == method. The original MatchData instance can be
  # obtained using the match_data accessor. Upon creation a clone of the passed
  # in MatchData object is stored; this means that the $~ global variable can
  # be conveniently wrapped without having to worry that subsequent operations
  # will alter the contents of the variable.
  class MatchDataWrapper
    include Walrat::LocationTracking

    attr_reader :match_data

    # Raises if data is nil.
    def initialize data
      raise ArgumentError if data.nil?
      self.match_data = data
    end

    # The definition of this method, in conjunction with the == method, allows
    # automatic comparisons with String objects using the == method.
    # This is because in a parser matches essentially are Strings (just like
    # Exceptions and Pathnames); it's just that this class encapsulates a
    # little more information (the match data) for those who want it.
    def to_str
      self.to_s
    end

    # Although this method explicitly allows for MatchDataWrapper to
    # MatchDataWrapper comparisons, note that all such comparisons will return
    # false except for those between instances which were initialized with
    # exactly the same match data instance; this is because the MatchData class
    # itself always returns false when compared with other MatchData instances.
    def ==(other)
      if other.kind_of? MatchDataWrapper
        self.match_data == other.match_data
      elsif other.respond_to? :to_str
        self.to_str == other.to_str
      else
        false
      end
    end

    def to_s
      @match_data[0]
    end

    def jlength
      self.to_s.jlength
    end

  private

    def match_data=(data)
      @match_data = (data.clone rescue data)
    end
  end # class MatchDataWrapper
end # module Walrat
