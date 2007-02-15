# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    require 'walrus/grammar/predicate'
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
        raise ParseError.new('predicate not satisfied ("%s" not allowed) while parsing "%s"' % [@parseable.to_s, string])
      end
      
    private
      
      def hash_offset
        11
      end
      
    end
    
  end # class Grammar
end # module Walrus
