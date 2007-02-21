# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Compiler
    
    BODY_INDENT     = ' ' * 6
    OUTSIDE_INDENT  = ' ' * 4
    
    # Walks the Abstract Syntax Tree, tree, that represents a parsed Walrus template.
    # Returns a String that defines a Document subclass corresponding to the compiled version of the tree.
    def compile(tree, class_name = 'DocumentSubclass')
      
      # everything that produces output (placeholders, rawtext etc) is implicitly included in the "template_body" block
      # there are somethings which explicitly occur outside of the "template_body" block: #def blocks for example.
      
      template_body = [] # will accumulate items for body, and joins them at the end of processing
      outside_body = [] # will accumulate items for outside of body, and joins them at the end of processing
      
      # make sure that tree responds to each (could also just add "each" method to Node)
      tree = [tree] unless tree.respond_to? :each
      
      # track whether "#import" and "#extends" have been used
      # it is only legal to use these at the top level of a template (ie. they cannot be nested inside #defs or #blocks)
      # only #import or #extends may be used in a given template, not both
      # calling #import or #extends more than once in a given template raises a CompileError
      import_directive  = nil
      extends_directive = nil
      
      # begin tree walk
      tree.each do |element|
        if element.kind_of? WalrusGrammar::DefDirective         # merely defines a block, doesn't output it
          
          # how to handle nesting here: if a two element array is returned, expect it to be [outside, inside] (nil is ok)
          # otherwise, just assume it is for the inside?
          
          element.compile.each { |line| outside_body  << OUTSIDE_INDENT + line } 
          if element.kind_of? WalrusGrammar::BlockDirective    # special case of block: defines a block and includes its output in the template_body
            template_body << BODY_INDENT    + "accumulate($#{element.identifier})\n"
          end
        elsif element.kind_of? WalrusGrammar::ExtendsDirective  # defines superclass and automatically invoke #super (super) at the head of the template_body
          raise CompileError.new('#extends may be used only once per template') unless extends_directive.nil?
          raise CompileError.new('illegal #extends (#import already used in this template)') unless import_directive.nil?
          extends_directive = element.class_name
        elsif element.kind_of? WalrusGrammar::ImportDirective   # defines superclass with no automatic invocation of #super on the template_body
          raise CompileError.new('#import may be used only once per template') unless import_directive.nil?
          raise CompileError.new('illegal #import (#extends already used in this template)') unless extends_directive.nil?
          import_directive = element.class_name
        elsif element.kind_of? WalrusGrammar::RawText           # special case: don't split RawText into lines because it may already include literal newline
          template_body << BODY_INDENT + element.compile
        else                                                    # everything else gets added to the template_body
          element.compile.each { |line| template_body << BODY_INDENT + line } # indent by 6 spaces
        end
      end
      
      superclass_name = import_directive || extends_directive || 'Document'
      if superclass_name != 'Document'  :   superclass_implementation = superclass_name.to_require_name
      else                                  superclass_implementation = 'walrus/document'
      end
      
      <<-RETURN
#!/usr/bin/env ruby
# Generated #{Time.new.to_s} by Walrus version #{VERSION}

require '#{superclass_implementation}'

module Walrus
  
  class #{class_name} < #{superclass_name}
    
    def template_body
      
#{template_body.join}
    end
    
#{outside_body.join}    
    if __FILE__ == $0   # when run from the command line the default action is to call 'run'
      self.new.run
    else                # in other cases, evaluate 'fill' (if run inside an eval, will return filled content)
      self.new.fill
    end
    
  end # #{class_name}
  
end # Walrus

      RETURN
      
    end
    
  end # class Compiler
end # module Walrus

