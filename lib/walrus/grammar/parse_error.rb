# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    class ParseError < Exception
      
      # take an optional hash (for packing extra info into exception?)
      # position in string (irrespective of line number, column number)
      # line number, column number
      # filename
      #def initialize(message)
      # super message
      #end
      
    end # class ParseError
    
  end # class Grammar
end # module Walrus

