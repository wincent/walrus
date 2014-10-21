# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar/ruby_expression'

module Walrus
  class Grammar
    class MessageExpression < RubyExpression
      def compile options = {}
        # simple case
        @target.source_text + '.' + @message.source_text
      end
    end # class MessageExpression
  end # class Grammar
end # Walrus
