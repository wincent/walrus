# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    class EscapeSequence < Walrat::Node
      def compile options = {}
        "accumulate(%s) \# EscapeSequence\n" % @lexeme.to_s.dump
      end
    end
  end # class Grammar
end # Walrus
