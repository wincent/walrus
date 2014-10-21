# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar/comment'

module Walrus
  class Grammar
    class MultilineComment < Comment
      using StringAdditions

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
