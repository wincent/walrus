# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    # "The #slurp directive eats up the trailing newline on the line it
    # appears in, joining the following line onto the current line."
    # http://www.cheetahtemplate.org/docs/users_guide_html_multipage/output.slurp.html
    # The "slurp" directive must be the last thing on the line (not followed
    # by a comment or directive end marker)
    class SlurpDirective < Directive
      # The slurp directive produces no meaningful output; but we leave a
      # comment in the compiled template so that the location of the directive
      # is visible in the source.
      def compile options = {}
        "# Slurp directive\n"
      end
    end # class SlurpDirective
  end # class Grammar
end # Walrus
