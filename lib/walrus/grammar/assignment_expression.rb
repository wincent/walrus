# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar/ruby_expression'

module Walrus
  class Grammar
    class AssignmentExpression < RubyExpression
      def compile options = {}
        @lvalue.source_text + '=' + @expression.source_text
      end
    end # class AssignmentExpression
  end # class Grammar
end # Walrus
