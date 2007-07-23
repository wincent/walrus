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
#
# $Id: and_predicate.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus'

module Walrus
  class Grammar
    
    class AndPredicate < Predicate
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        catch :ZeroWidthParseSuccess do
          begin
            parsed = @parseable.memoizing_parse(string, options)
          rescue ParseError
            raise ParseError.new('predicate not satisfied (expected "%s") while parsing "%s"' % [@parseable.to_s, string],
                                 :line_end => options[:line_start], :column_end => options[:column_start])
          end
        end
        
        # getting this far means that parsing succeeded (just what we wanted)
        throw :AndPredicateSuccess # pass succeeded
      end
      
    private
      
      def hash_offset
        12
      end
      
    end
    
  end # class Grammar
end # module Walrus
