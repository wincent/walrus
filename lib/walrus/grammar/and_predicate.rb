# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

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
