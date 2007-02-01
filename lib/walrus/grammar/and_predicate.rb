# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    require 'walrus/grammar/predicate'
    class AndPredicate < Predicate
      
      def parse(string)
        raise ArgumentError if string.nil?
        catch(:ZeroWidthParseSuccess) do
          begin
            @parseable.parse(string)
          rescue ParseError
            raise ParseError.new('predicate not satisfied (expected "%s") while parsing "%s"' % [@parseable.to_s, string])
          end
        end
        
        # getting this far means that parsing succeeded (just what we wanted)
        throw :AndPredicateSuccess # pass succeeded
      end
      
    end
    
  end # class Grammar
end # module Walrus
