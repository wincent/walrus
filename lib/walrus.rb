# Copyright 2007 Wincent Colaiuta
# $Id$

# General purpose utility methods useful across all Walrus classes
module Walrus
  
  VERSION='1.0b'
  
  module CamelCase
    
    # Converts strings of the form "FooBar" to "foo_bar".
    # Note that some information loss may be incurred; for example, "EOL" would be reduced to "token".
    # Raises an ArgumentError if the string parameter is nil.
    def require_name_from_classname(string)
      
      raise ArgumentError.new("string is not a valid classname") unless string =~ /^[A-Z][A-Za-z0-9_]*$/
      
      # insert an underscore before any initial capital letters
      base = string.gsub(/([^A-Z_])([A-Z])/, '\1_\2')
  
      # consecutive capitals are words too, excluding any following capital that belongs to the next word
      base.gsub!(/([A-Z])([A-Z])([^A-Z0-9_])/, '\1_\2\3')
      
      # numbers mark the start of a new word
      base.gsub!(/([^0-9_])(\d)/, '\1_\2')
      
      # numbers also mark the end of a word
      base.gsub!(/(\d)([^0-9_])/, '\1_\2')
      
      # lowercase everything
      base.downcase
      
    end
    
    # Converts strings of the form "foo_bar" to "FooBar".
    # Note that this method cannot recover information lost during a conversion using the require_name_from_classname method; for example, "EOL", when converted to "token", would be transformed back to "EolToken". Likewise, "Foo__bar" would be reduced to "foo__bar" and then in the reverse conversion would become "FooBar".
    # Raises an ArgumentError if the string parameter is nil.
    def classname_from_require_name(string)
      raise ArgumentError.new("string is not a valid require name") unless string =~ /^[a-z][a-z0-9_]*$/
      string.split("_").collect { |component| component.capitalize}.join
    end
    
    def to_class_name
      classname_from_require_name(self)
    end
    
    def to_require_name
      require_name_from_classname(self)
    end
    
  end # module CamelCase
    
end # module Walrus
