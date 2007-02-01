# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  # An exception subclass designed to encapsulate filename, line number and column information when errors occur during lexing, parsing or other string processsing.
  class StringProcessingError < Exception

    attr_reader   :filename
    attr_reader   :line_number
    attr_reader   :column_number

    def initialize(message, filename, line_number, column_number)
      super(message)
      self.message        = message
      self.filename       = filename
      self.line_number    = line_number
      self.column_number  = column_number
    end

    def location
  
      # fallback values
      if @line_number
        line = @line_number.to_s
      else
        line = "?"
      end
      if @column_number
        column = @column_number.to_s
      else 
        column = "?"
      end
  
      if @filename
        return "%s:%s:%s" % [ @filename, line, column ]
      else
        return "%s:%s" % [ line, column]
      end
    end

    def to_s
      if @message 
        return "%s (%s at %s)" % [ @message, self.class.to_s, self.location ]
      else
        return "%s at %s" % [ self.class.to_s, self.location ]
      end
    end

    def message=(message)
      @message = (message.clone rescue message)
    end

    def filename=(filename)
      @filename = (filename.clone rescue filename)
    end

    def line_number=(line_number)
      @line_number = (line_number.clone rescue line_number)
    end

    def column_number=(column_number)
      @column_number = (column_number.clone rescue column_number)
    end  

  end # class StringProcessingError
end # module Walrus
