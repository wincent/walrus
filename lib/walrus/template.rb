# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Template
    
    attr_reader   :base_text
    
    # If initialized using a Pathname or File, returns the pathname. Otherwise returns nil.
    attr_reader   :origin
    
    # Accepts input of class String, Pathname or File
    def initialize(input)
      raise ArgumentError if input.nil?
      if input.respond_to? :read # should work with Pathname or File
        @base_text  = input.read
        @origin     = input.to_s
      else
        @base_text  = input.to_s.clone
      end
    end
    
    # The fill method returns a string containing the output produced when executing the compiled template.
    def fill
      @filled ||= instance_eval(compiled)
    end
    
    def filled
      fill
    end
    
    # Parses template, returning compiled input (suitable for writing to disk).
    def compile
      @parser   ||= Parser.new
      @compiled ||= @parser.compile(@base_text, :class_name => class_name, :origin => @origin)
    end
    
    # Returns the compiled text of the receiver
    def compiled
      compile
    end
    
    # Prints output obtained by running the compiled template.
    def run
      p fill
    end
    
    def class_name
      if @class_name
        @class_name
      else
        if @origin.nil? : @class_name = Compiler::DEFAULT_CLASS # "DocumentSubclass"
        else              @class_name = File.basename(@origin, File.extname(@origin)).to_class_name
        end
      end
    end
    
  end # class Template
end # module Walrus
