# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    autoload(:AndPredicate,       'walrus/grammar/and_predicate')
    autoload(:NotPredicate,       'walrus/grammar/not_predicate')
    autoload(:ParsletChoice,      'walrus/grammar/parslet_choice')
    autoload(:ParsletMerge,       'walrus/grammar/parslet_merge')
    autoload(:ParsletOmission,    'walrus/grammar/parslet_omission')
    autoload(:ParsletRepetition,  'walrus/grammar/parslet_repetition')
    autoload(:ParsletSequence,    'walrus/grammar/parslet_sequence')
    
    # The ParsletCombining module, together with the ParsletCombination class and its subclasses, provides simple container classes for encapsulating relationships among Parslets. By storing this information outside of the Parslet objects themselves their design is kept clean and they can become immutable objects which are much more easily copied and shared among multiple rules in a Grammar.
    module ParsletCombining
      
      # Convenience method.
      def memoizing_parse(string, options = {})
        self.to_parseable.memoizing_parse(string, options)
      end
      
      # Convenience method.
      def parse(string, options = {})
        self.to_parseable.parse(string, options)
      end
      
      # Defines a sequence of Parslets (or ParsletCombinations).
      # Returns a ParsletSequence instance.
      def sequence(first, second, *others)
        Walrus::Grammar::ParsletSequence.new(first.to_parseable, second.to_parseable, *others)
      end
      
      # Shorthand for ParsletCombining.sequence(first, second).
      def &(next_parslet)
        self.sequence(self, next_parslet)
      end
      
      # Defines a sequence of Parslets similar to the sequence method but with the difference that the contents of array results from the component parslets will be merged into a single array rather than being added as arrays. To illustrate:
      #
      #   'foo' & 'bar'.one_or_more   # returns results like ['foo', ['bar', 'bar', 'bar']]
      #   'foo' >> 'bar'.one_or_more  # returns results like ['foo', 'bar', 'bar', 'bar']
      #
      def merge(first, second, *others)
        Walrus::Grammar::ParsletMerge.new(first.to_parseable, second.to_parseable, *others)
      end
      
      # Shorthand for ParsletCombining.sequence(first, second)
      def >>(next_parslet)
        self.merge(self, next_parslet)
      end
      
      # Defines a choice of Parslets (or ParsletCombinations).
      # Returns a ParsletChoice instance.
      def choice(left, right, *others)
        Walrus::Grammar::ParsletChoice.new(left.to_parseable, right.to_parseable, *others)
      end
      
      # Shorthand for ParsletCombining.choice(left, right)
      def |(alternative_parslet)
        self.choice(self, alternative_parslet)
      end
      
      # Defines a repetition of the supplied Parslet (or ParsletCombination).
      # Returns a ParsletRepetition instance.
      def repetition(parslet, min, max)
        Walrus::Grammar::ParsletRepetition.new(parslet.to_parseable, min, max)
      end
      
      # Shorthand for ParsletCombining.repetition.
      def repeat(min = nil, max = nil)
        self.repetition(self, min, max)
      end
      
      # Shorthand for ParsletCombining.repetition(0, 1).
      # TODO: All this method to take an optional parameter specifying what object should be returned as a placeholder when there are no matches (useful for packing into ASTs).
      # should be very quick to implement using a ParsletRepetition subclass which catches ZeroWidthParseSuccess and returns the placeholder (or better, a copy of it).
      def optional
        self.repeat(0, 1)
      end
      
      # Alternative to optional.
      def zero_or_one
        self.optional
      end
      
      # possible synonym "star"
      def zero_or_more
        self.repeat(0)
      end
      
      # possible synonym "plus"
      def one_or_more
        self.repeat(1)
      end
      
      # Parsing Expression Grammar support.
      # Succeeds if parslet succeeds but consumes no input (throws an :AndPredicateSuccess symbol).
      def and_predicate(parslet)
        Walrus::Grammar::AndPredicate.new(parslet.to_parseable)
      end
      
      # Shorthand for and_predicate
      # Strictly speaking, this shorthand breaks with established Ruby practice that "?" at the end of a method name should indicate a method that returns true or false.
      def and?
        self.and_predicate(self)
      end
      
      # Parsing Expression Grammar support.
      # Succeeds if parslet fails (throws a :NotPredicateSuccess symbol).
      # Fails if parslet succeeds (raise a ParseError).
      # Consumes no output.
      # This method will almost invariably be used in conjuntion with the & operator, like this:
      #       rule :foo, :p1 & :p2.not_predicate
      #       rule :foo, :p1 & :p2.not!
      def not_predicate(parslet)
        Walrus::Grammar::NotPredicate.new(parslet.to_parseable)
      end
      
      # Shorthand for not_predicate.
      # Strictly speaking, this shorthand breaks with established Ruby practice that "!" at the end of a method name should indicate a destructive behaviour on (mutation of) the receiver.
      def not!
        self.not_predicate(self)
      end
      
      # Succeeds if parsing succeeds, consuming the output, but doesn't actually return anything.
      # This is for elements which are required but which shouldn't appear in the final AST.
      def omission(parslet)
        Walrus::Grammar::ParsletOmission.new(parslet.to_parseable)
      end
      
      # Shorthand for ParsletCombining.omission
      def skip
        self.omission(self)
      end
      
    end # module ParsletCombining
    
  end # class Grammar
end # module Walrus
