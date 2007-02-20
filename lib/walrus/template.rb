# Copyright 2007 Wincent Colaiuta
# $Id$

require 'pathname'
require 'walrus'

module Walrus
  class Template
    
    attr_accessor :base_text
    
    # If initialized using a Pathname or File, returns the pathname. Otherwise returns nil.
    attr_reader   :origin
    
    # Accepts input of class String, Pathname or File
    def initialize(input)
      raise ArgumentError if @origin.nil?
      if input.respond_to? :read # should work with Pathname or File
        contents = input.read
        raise IOError if not contents.kind_of? String
        @base_text  = contents
        @origin     = input.to_s
      else
        @base_text  = input.clone
      end
    end
    
    # The fill method returns a string containing the output produced when executing the compiled template.
    def fill
      compiled = ''
      result = nil
      begin
        compiled = self.compiled_text
        result = eval(compiled)
      rescue Exception => exception
        source = @origin ? @origin : @base_text
        #raise Exception.exception(' %s (%s: %s)' % [ exception.message, source, compiled ])
      end
      result || ''
    end
    
    # Parses template, returning compiled input (suitable for writing to disk).
    def compile
      
      tokens    = Lexer.new(@base_text).tokens
      tree      = Parser.new(tokens)
      compiled  = tokens.collect { |token| token.compiled_string }
      output    = compiled.join("\n")
      
      # TODO: ask tree what the superclass is, if none, that means it's "Document"
      
      # TODO: instead of just indiscriminately overriding template_body, parser should tell us whether to insert:
      #
      # def template_body
      #   super
      #   do_the_rest
      # end
      #
      # or just forget the call to super
      # really the parser needs to return all that for us, ready to go
      
      
      
      class_name = self.class_name
      superclass_name = 'Document'
      superclass_path = 'walrus/document'
      <<-EOS
        # Generated #{Time.new.to_s} by Walrus version #{VERSION}
        
        require '#{superclass_path}'
        
        module Walrus
          
          class #{class_name} < #{superclass_name}
            
            def template_body
              #{output}
            end
            
            if __FILE__ == $0
              # When run from the command line the default action is to call "run"
              self.new().run
            else
              # in other cases, evaluate "fill" (if run inside an eval, will return filled content)
              self.new().fill
            end
            
          end # class #{class_name}
          
        end # module Walrus
        
      EOS
    
    end
    
    def compiled_text
      self.compile
    end
    
    # Prints output obtained by running the compiled template.
    def run
      p self.fill
    end
    
    def class_name
      if @origin.nil? : "DocumentSubclass"
      else              File.basename(@origin, ".rb").to_class_name
      end
    end
    
  end # class Template
end # module Walrus
