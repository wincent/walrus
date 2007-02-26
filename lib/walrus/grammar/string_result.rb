# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    class StringResult < String
      
      include Walrus::Grammar::LocationTracking
      
      def initialize(string = "")
        self.source_text = string
        super
      end
      
    end # class StringResult
  end # class Grammar
end # module Walrus
