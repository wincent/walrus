# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    class RubyExpression < Walrat::Node
      # Rather than just compiling Ruby expressions back to text in a generic
      # fashion it is desirable to compile the pieces separately (for an
      # example, see the AssignmentExpression class) because this allows us to
      # handle placeholders embedded inside Ruby expressions.
      #
      # Nevertheless, at an abstract level we here supply a default compilation
      # method which just returns the source text, suitable for evaluation.
      # Subclasses can then override this as new cases are discovered which
      # require piece-by-piece compilation.
      def compile options = {}
        source_text
      end
    end # class RubyExpression
  end # class Grammar
end # Walrus
