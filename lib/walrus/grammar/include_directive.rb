# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    class IncludeDirective < Directive
      def compile options = {}
        inner, outer = options[:compiler_instance].compile_subtree(subtree)
        inner = [] if inner.nil?
        inner.unshift "\# Include (start): #{file_name.to_s}:\n"
        [inner, outer]
      end
    end # class IncludeDirective
  end # class Grammar
end # Walrus
