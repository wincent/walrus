# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    class ContinuationWrapperException < Exception
      
      attr_reader :continuation
      
      def initialize(continuation)
        raise ArgumentError if continuation.nil?
        super self.class.to_s
        @continuation = continuation
      end
      
    end # class ContinuationWrapperException
    
  end # class Grammar
end # module Walrus

