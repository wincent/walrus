# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/string_processing_error'

module Walrus
  class ParserError < StringProcessingError
  
    # Given that the parser is always working with tokens (which should encapsulate some information about their origin), the ParserError class provides a simpler initialize method than its superclass. All parameters are optional.
    def initialize(message, token)
      if token
        filename      = token.filename
        line_number   = token.line_number
        column_number = token.column_number
      else
        filename      = nil
        line_number   = nil
        column_number = nil
      end
      super(message, filename, line_number, column_number)
    end
  
  end # class ParserError
end # module Walrus
