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
  module Memoizing
    # This method provides a clean, optional implementation of memoizing by
    # serving as a wrapper for all parse invocations. Rather than calling the
    # parse methods directly, this method should be called; if it is
    # appropriate to use a memoizer then it will be invoked, otherwise control
    # will fall through to the real parse method. Turning off memoizing is as
    # simple as not passing a value with the :memoizer key in the options hash.
    # This method defined is in a separate module so that it can easily be
    # mixed in with all Parslets, ParsletCombinations and Predicates.
    def memoizing_parse(string, options = {})
      # will use memoizer if available and not instructed to ignore it
      if options.has_key?(:memoizer) and not
         (options.has_key?(:ignore_memoizer) and options[:ignore_memoizer])
        options[:parseable] = self
        options[:memoizer].parse string, options
      else # otherwise will proceed as normal
        options[:ignore_memoizer] = false
        parse string, options
      end
    end

    # Can only check for left recursion if memoizing is turned on (the help of
    # the memoizer is needed).
    def check_left_recursion parseable, options = {}
      return unless options.has_key?(:memoizer)
      options[:memoizer].check_left_recursion parseable, options
    end
  end # module Memoizing
end # module Walrat

