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
    
    class NotPredicate < Predicate
      
      def parse(string, options = {})
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
                             :line_end => options[:line_start], :column_end => options[:column_start])
      end
      
    private
      
      def hash_offset
        11
      end
      
    end
    
  end # class Grammar
end # module Walrus