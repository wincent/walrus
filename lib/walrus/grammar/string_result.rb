# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    class StringResult < String
      
      include Walrus::Grammar::LocationTracking
      
    end # class StringResult
  end # class Grammar
end # module Walrus
