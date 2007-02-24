# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    class ArrayResult < Array
      
      include LocationTracking
      
    end # class ArrayResult
  end # class Grammar
end # module Walrus
