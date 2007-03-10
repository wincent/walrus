# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    class LeftRecursionException < Exception
      
      # attr_reader :continuation
      # 
      # def initialize(continuation = nil)
      #   super self.class.to_s
      #   @continuation = continuation
      # end
      
    end # class LeftRecursionException
    
  end # class Grammar
end # module Walrus

