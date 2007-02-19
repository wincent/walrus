# Copyright 2007 Wincent Colaiuta
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
            raise ParseError.new('predicate not satisfied (expected "%s") while parsing "%s"' % [@parseable.to_s, string])
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
