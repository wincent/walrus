# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    class SetDirective < Directive
      def compile options = {}
        "set_value(%s, instance_eval { %s }) # Set directive\n" %
          [ @placeholder.to_s.dump, @expression.compile ]
      end
    end # class SetDirective
  end # class Grammar
end # Walrus
