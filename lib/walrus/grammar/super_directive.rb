# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    class SuperDirective < Directive
      def compile options = {}
        # basic case, no explicit parameters
        "super # Super directive\n"
      end
    end # class SuperDirective
  end # class Grammar
end # Walrus
