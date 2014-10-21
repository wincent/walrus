# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    class RawText < Walrat::Node
      using StringAdditions

      # Returns a string containing the compiled (Ruby) version of receiver.
      # If options[:slurping] is true, instructs the receiver to strip the
      # leading carriage return/line feed from the @lexeme prior to emitting
      # the compiled output.
      def compile options = {}
        lexeme = options[:slurping] ? to_s.sub(/\A(\r\n|\r|\n)/, '') : to_s

        compiled  = ''
        first     = true
        lexeme.to_source_string.each do |line|
          newline = ''
          if line =~ /(\r\n|\r|\n)\z/       # check for literal newline at end of line
            line.chomp!                     # get rid of it
            newline = ' + ' + $~[0].dump    # include non-literal newline instead
          end

          if first
            compiled << "accumulate('%s'%s) # RawText\n" % [ line, newline ]
            first = false
          else
            compiled << "accumulate('%s'%s) # RawText (continued)\n" % [ line, newline ]
          end
        end
        compiled
      end
    end # class RawText
  end # class Grammar
end # Walrus
