# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Compiler
    
    
=begin

Code pasted from token subclasses prior to refactoring:

=end
    # Returns a string containing the compiled (Ruby) version of the passed text token. By using a format string that accepts as input an array of UTF-8 characters we avoid having to escape characters or sequences that would otherwise have a special meaning in Ruby.
    def compile_text_token(token)
      
      # get the numeric values (UTF-8)
      values = token.text_string.unpack('U*')
      
      # now build up compiled sting for completing round trip
      compiled = 'self.accumulate([ '
      values.each { |number| compiled << '%d, ' % number } 
      compiled.sub!(/, $/, ' ')       # trailing comma is harmless, but suppress it anyway for aesthetics
      compiled << "].pack('U*'))"
      
      # TODO: embed original line and column number in comment?
    
    end
    
    def compile_silent_eol_token(token)
      if token.line_number
        '# (non-printing) END-OF-LINE (Line: %d)' % token.line_number
      else
        '# (non-printing) END-OF-LINE'
      end
    end
    
    # Comments compile down to nothing so this method always returns nil.
    def compile_comment_token(token)
      
      # for now just return nil
      return nil
      
      # TODO: but consider returning the comment literally
      # this would require that comments only include valid ruby comment characters
      # could return something like this:
      # # <COMMENT SOURCE="template_filename:line_number:column">
      # ## The actual comment
      # # </COMMENT>
      
      if @line_number
        compiled = "# <Comment (Line: %d)>\n%" % @line_number
      else
        compiled = "# <Comment>\n"
      end
      compiled << @comment_string
      compiled << "\n"
      compiled << '# </Comment>'
      compiled
      
    end
    
    def compile_eol_token(token)
      if token.line_number
        '# END-OF-LINE (Line: %d)' % token.line_number
      else
        '# END-OF-LINE'
      end
    end
    
  end # class Compiler
end # module Walrus

