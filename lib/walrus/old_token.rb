# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  module Token
    
    # The Token class is an abstract superclass; most of the real functionality is implemented by subclasses.
    # TODO: decide whether this is actually the right approach: I might be better of with a single Token class and no subclasses; the Parser (or a "Compiler" class) handles the generation of compiled strings
    class Token
    
      attr_reader :text_string
    
      # The file name of the file in which the token appears. Tokens don't necessarily know where they are in the input stream. It's up to the lexer to maintain the filename property.
      # May be nil.
      attr_reader :filename
    
      # The line number on which the token begins. Tokens don't necessarily know where they are in the input stream. It's up to the lexer to maintain the line number property.
      attr_reader :line_number
    
      # The column number on which the token begins. Tokens don't necessarily know where they are in the input stream. It's up to the lexer to maintain the column number property.
      attr_reader :column_number
    
      def initialize(*location)
        if location.length == 2     # expect line number, column number
          self.location = [location[0], location[1]]
        end
      end
    
      def to_s
        @text_string
      end
    
      # Subclasses should override this method to produce the appropriate compiled output.
      def compiled_string
        raise NotImplementedError
      end
    
      # Convenience method for simultaneously setting the line and column numbers. Expects an Array containing two numeric elements, line and column.
      def location=(array)
        raise ArgumentError.new('array must have two elements') unless array.length == 2 
        self.line_number    = array[0]
        self.column_number  = array[1]
      end
    
      def filename=(name)
        @filename = (name.clone rescue name)
      end
    
      def line_number=(line)
        @line_number = (line.clone rescue line)
      end
    
      def column_number=(column)
        @column_number = (column.clone rescue column)
      end
    
      # Convenience method for determining if a Token is a Comment, should be overridden by the Comment subclass.
      def comment?
        false
      end
    
      def directive?
        false
      end
    
      def token?
        false
      end
    
      def placeholder?
        false
      end
    
      def ruby?
        false
      end
    
      def silent_token?
        false
      end
    
      def text?
        false
      end
    
    end
  end
end
