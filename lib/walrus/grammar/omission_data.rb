# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    module OmissionData
      
      attr_accessor :omitted
      
      # Convenience method.
      def omitted_length
        self.omitted.to_s.length
      end
      
    end # module OmissionData
    
  end # class Grammar
end # module Walrus
