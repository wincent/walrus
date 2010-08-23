# Copyright 2007-2010 Wincent Colaiuta. All rights reserved.
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

require 'walrus/grammar/comment'

module Walrus
  class Grammar
    class MultilineComment < Comment
      # Multiline comments may contain nested Comments/Multiline comments or
      # normal text, so must compile recursively.
      #
      # TODO: anchor comments that appear immediately before #def and #block
      # directives to their corresponding methods (for the timebeing should
      # note in the documentation that if you want your comments to appear
      # adjacent to the blocks which follow them then you must put your
      # comments inside the blocks)
      def compile options = {}
        compiled = ''
        if @content.respond_to? :each
          @content.each do |item|
            if item.kind_of? Comment
              compiled << '# (nested) ' + item.compile
            else
              first = true
              item.to_s.each do |line|
                if first
                  first = false
                  compiled << '# MultilineComment:' + line.to_s.chomp + "\n"
                else
                  compiled << '# MultilineComment (continued):' + line.to_s.chomp + "\n"
                end
              end
            end
          end
        else
          # no nesting, just raw text, but still must check for multiple lines
          first = true
          @content.to_s.each do |line|
            if first
              first = false
              compiled << '# MultilineComment:' + line.to_s.chomp + "\n"
            else
              compiled << '# MultilineComment (continued):' + line.to_s.chomp + "\n"
            end
          end
        end
        compiled
      end
    end
  end # class Grammar
end # Walrus
