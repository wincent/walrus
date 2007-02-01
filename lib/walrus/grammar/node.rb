# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    # Make subclasses of this for us in Abstract Syntax Trees (ASTs).
    class Node
      
      # :skip means that parameter won't appear in AST.
      #
      # Example:
      #
      # Given this source:
      #
      #   target = expression
      #
      # We would want to represent this using an "Assignment" Node in the AST:
      #
      #   Node.subclass(:Assignment, :assignment_target, :skip, :assignment_expression)
      #
      # Would create this class:
      #
      #   class Assignment < Node
      #     attr_reader :assignment_target, :assignment_expression
      #     def initialize(assignment_target, assignment_expression)
      #       @assignment_target = assignment_target
      #       @assignment_expression = assignment_expression
      #     end
      #   end
      #
      # subclass should be a Symbol
      # args are optional symbols describing the contents of the AST
      # :symbol would be a named attribute
      # :Class would be a subnode class
      # :skip means the parameter won't appear in the AST
      #
      # Example:
      #
      #
      def subclass(subclass, *args)
        # create new anonymous class with Node as superclass, assigning it to a constant effectively names the class
        
        # TODO: consider here instead creating subclasses in the namespace of the Grammar subclass being defined
        new_class = Walrus::Grammar::const_set(subclass, Class.new(Node))
        
        # could be really complicated, even if i use a hash for internal storage and write "value for key" accessors
        # need also to decide how to represent lists (variable numbers of elements)
        # eg. how would your represent this array?
        # [ foo, bar, 1, 2 ]
        # maybe in that case I just need to return a real array
        <<-DEF
        DEF
        new_class.class_eval do
          def initialize(args)
            args.each { |arg| self.arg = }
          end
        end
        
        
        # set up accessors (using send because attr_accessor is private; in Ruby 1.9 will need to used funccall)
        args.each { |symbol| new_class.send(:attr_accessor, symbol) }
        
        
        # ideally would use attr_reader and then define private methods for setting the values
        # or just define the initialize method define_method
        # make methods private by calling private
        
        new_class
      end
      
    end # class Node
    
  end # class Grammar
end # module Walrus
