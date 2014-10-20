# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'walrus/grammar'
require 'walrus/additions/string'

module Walrus
  class Grammar
    class RawText < Walrat::Node
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
