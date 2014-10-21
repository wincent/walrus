# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    class Literal < Walrat::Node
      def compile options = {}
        @lexeme.source_text
      end
    end # class Literal
  end # class Grammar
end # Walrus
