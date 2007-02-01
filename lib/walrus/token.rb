# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  
  # A Token is basically a piece of text with some additional attributes.
  class Token
    
    attr_reader :type
    
    attr_reader :text_string
    
    # The line number on which the Token begins. Since Tokens don't necessarily know where they are in the input stream, it's up to the Lexer to maintain the line number property.
    # May be nil.
    attr_reader :line_number
    
    # The column number on which the Token begins. Since Tokens don't necessarily know where they are in the input stream, it's up to the Lexer to maintain the column number property.
    # May be nil.
    attr_reader :column_number
    
    # The file name of the file in which the Token appears. Since Tokens don't necessarily know where they are in the input stream, it's up to the Lexer to maintain the filename property.
    # May be nil.
    attr_reader :filename
    
    # Required parameters are type and text_string.
    # Optional parameters are line_number, column_number and filename.
    def initialize(type, text_string, *location)
      raise ArgumentError.new('nil type')         if type.nil?
      raise ArgumentError.new('nil text_string')  if text_string.nil?
      self.type           = type
      self.text_string    = text_string
      self.line_number    = location[0]
      self.column_number  = location[1]
      self.filename       = location[2]
      @key_value_pairs    = {}
    end
    
    def initialize_copy(from)
      self.type           = from.type
      self.text_string    = from.text_string
      self.line_number    = from.line_number
      self.column_number  = from.column_number
      self.filename       = from.filename
      @key_value_pairs    = Marshal.load(Marshal.dump(from.key_value_pairs)) # deep copy
    end
    
    def == (other)
      return false if not other.kind_of?(self.class) or
      other.type            != @type or
      other.text_string     != @text_string or
      other.line_number     != @line_number or
      other.column_number   != @column_number or
      other.filename        != @filename or
      other.key_value_pairs != @key_value_pairs
      return true
    end
    
    # Returns raw text used to initialize the receiver.
    def to_s
      @text_string
    end
    
    def value_for_key(key)
      @key_value_pairs[key]
    end
    
    # TODO: Consider setting up a method_missing method to automatically catch these things?
    def set_value_for_key(value, key)
      @key_value_pairs[key] = value
    end
    
    def key_value_pairs
      @key_value_pairs
    end
    
    def type=(type)
      @type = (type.clone rescue type)
    end
    
    def text_string=(text_string)
      @text_string = (text_string.clone rescue type)
    end
    
    # Convenience method for simultaneously setting the line and column numbers. Expects an Array containing two numeric elements, line and column.
    def location=(array)
      raise ArgumentError.new('array must have two elements') unless array.length == 2 
      self.line_number    = array[0]
      self.column_number  = array[1]
    end
    
    def line_number=(line)
      @line_number = (line.clone rescue line)
    end
    
    def column_number=(column)
      @column_number = (column.clone rescue column)
    end
    
    def filename=(name)
      @filename = (name.clone rescue name)
    end
    
    # Convenience method for determining if a Token is a comment.
    def comment?
      @type == :comment
    end
    
    def directive?
      @type == :directive
    end
    
    def eol?
      @type == :eol
    end
    
    def identifier?
      @type == :identifier
    end
    
    def placeholder?
      @type == :placeholder
    end
    
    def ruby?
      @type == :ruby
    end
    
    def silent_eol?
      @type == :silent_eol
    end
    
    def text?
      @type == :text
    end
    
  end # class token
end # module Walrus
