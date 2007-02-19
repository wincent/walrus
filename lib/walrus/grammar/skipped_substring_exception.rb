# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    # I don't really like using Exceptions for non-error situations, but it seems that using throw/catch here would not be adequate (not possible to embed information in the thrown symbol).
    class SkippedSubstringException < Exception
      
    end # class SkippedSubstringException
    
  end # class Grammar
end # module Walrus

