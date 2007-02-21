# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class MultilineComment
      
      # Multiline comments may containing nested Comments/Multiline comments or normal text, so must compile recursively.
      # TODO: Make compiled output less ugly (currently not nicely indented; perhaps should indent all but first line by 6 spaces)
      # TODO: anchor comments that appear immediately before #def and #block directives to their corresponding methods (for the timebeing should note in the documentation that if you want your comments to appear adjacent to the blocks which follow them then you must put your comments inside the blocks)
      def compile
        compiled = ''
        if @content.respond_to? :each
          @content.each do |item|
            if item.kind_of? MultilineComment
              compiled << '# MultilineComment:' + item.compile
            elsif item.kind_of? Comment
              compiled << '# MultilineComment:' + item.compile 
            else
              compiled << '# MultilineComment:' + item.to_s + "\n"
            end
          end
        else # no nesting, just raw text, but still must check for multiple lines
          @content.to_s.each do |line|
            compiled << '# MultilineComment:' + line.to_s + "\n"
          end
        end
        compiled
      end
      
    end
    
  end # class WalrusGrammar
end # Walrus

