# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    # "Any section of a template definition that is inside a #raw ... #end
    # raw tag pair will be printed verbatim without any parsing of
    # $placeholders or other directives."
    # http://www.cheetahtemplate.org/docs/users_guide_html_multipage/output.raw.html
    # Unlike Cheetah, Walrus uses a bare "#end" marker and not an "#end raw"
    # to mark the end of the raw block.
    # The presence of a literal #end within a raw block is made possible by
    # using an optional "here doc"-style delimiter:
    #
    # #raw <<END_MARKER
    #     content goes here
    # END_MARKER
    #
    # Here the opening "END_MARKER" must be the last thing on the line
    # (trailing whitespace up to and including the newline is allowed but it
    # is not considered to be part of the quoted text). The final
    # "END_MARKER" must be the very first and last thing on the line, or it
    # will not be considered to be an end marker at all and will be
    # considered part of the quoted text. The newline immediately prior to
    # the end marker is included in the quoted text.
    #
    # Or, if the end marker is to be indented:
    #
    # #raw <<-END_MARKER
    #     content
    #      END_MARKER
    #
    # Here "END_MARKER" may be preceeded by whitespace (and whitespace only)
    # but it must be the last thing on the line. The preceding whitespace is
    # not considered to be part of the quoted text.
    class RawDirective < Directive
      # Returns a string containing the compiled (Ruby) version of receiver.
      def compile options = {}
        compiled  = []
        first     = true
        @content.to_s.to_source_string.each do |line|
          newline = ''
          if line =~ /(\r\n|\r|\n)\z/       # check for literal newline at end of line
            line.chomp!                     # get rid of it
            newline = ' + ' + $~[0].dump    # include non-literal newline instead
          end

          if first
            compiled << "accumulate('%s'%s) # RawDirective\n" % [ line, newline ]
            first = false
          else
            compiled << "accumulate('%s'%s) # RawDirective (continued)\n" % [ line, newline ]
          end
        end
        compiled.join
      end
    end # class RawDirective
  end # class Grammar
end # Walrus
