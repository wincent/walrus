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
  class NotPredicate < Predicate
    def parse string, options = {}
      raise ArgumentError if string.nil?
      catch :ZeroWidthParseSuccess do
        begin
          @parseable.memoizing_parse(string, options)
        rescue ParseError # failed to pass (which is just what we wanted)
          throw :NotPredicateSuccess
        end
      end

      # getting this far means that parsing succeeded (not what we wanted)
      raise ParseError.new('predicate not satisfied ("%s" not allowed) while parsing "%s"' % [@parseable.to_s, string],
                           :line_end => options[:line_start],
                           :column_end => options[:column_start])
    end

  private

    def hash_offset
      11
    end
  end
end # module Walrat
