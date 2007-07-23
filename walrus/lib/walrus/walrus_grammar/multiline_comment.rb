# Copyright 2007 Wincent Colaiuta
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id: multiline_comment.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class MultilineComment
      
      # Multiline comments may containing nested Comments/Multiline comments or normal text, so must compile recursively.
      # TODO: anchor comments that appear immediately before #def and #block directives to their corresponding methods (for the timebeing should note in the documentation that if you want your comments to appear adjacent to the blocks which follow them then you must put your comments inside the blocks)
      def compile(options = {})
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
        else # no nesting, just raw text, but still must check for multiple lines
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
    
  end # class WalrusGrammar
end # Walrus

