# Copyright 2007 Wincent Colaiuta
# $Id$

require 'strscan'

require 'walrus/lexer_error'

module Walrus
  
  # LineScanner is a StringScanner subclass that adds a number of methods for lexing lines, returning Token subclasses where appropriate instead of Strings.
  class LineScanner < StringScanner
  
    attr_reader :line_number
  
    # Carriage return.
    CR="\r"
  
    # Linefeed.
    LF="\n"
  
    def initialize(string, *line_number)
      super
      raise ArgumentError.new('multi-line input') if string =~ /#{CR}|#{LF}/
      if line_number.length > 0
        raise ArgumentError.new('incorrect parameter count') if line_number.length != 1
        @line_number = line_number[0]
      end
    end
    
    # Lookahead helper method.
    # Accepts an enumerable collection of String or Regexp objects.
    # Returns the matching item which is closest to the scan position (scanning forward), or nil if none of the items match.
    # If more than one item matches at the same distance from the scan position, the first such item is returned.
    # Raises an ArgumentError if expressions is nil.
    def closest(expressions)
      raise ArgumentError.new('expressions is nil') if expressions.nil?
      raise ArgumentError.new('expressions does not respond to each') if not expressions.respond_to? :each
      distances = []
      expressions.each do |expression|
        
        # convert expression from String to Regexp if necessary
        regexp = expression.kind_of?(Regexp) ? expression : Regexp.new(Regexp.escape(expression))
        
        if self.exist?(regexp)                                  # search pattern exists
          distances.push([self.pre_match.length, expression])   # store starting position of search pattern
        else                                                    # search pattern not found
          distances.push(nil)
        end
      end
      
      # nil values don't respond to the comparison methods, so must do this manually
      closest = distances.min do |a, b|
        if a.nil? and b.nil?          : 0
        elsif a.nil? and not b.nil?   : 1
        elsif not a.nil? and b.nil?   : -1
        else                          a[0] <=> b[0] # compare the distance, even though return value is the actual expression
        end
      end
      
      closest ? closest[1] : nil    # return closest match (if one found) or nil if no matches
      
    end
    
    # Scan characters that do not have special meaning. Only three characters have special meaning in Walrus: hash, the dollar sign, and backwards slash. Returns a Text instance, or nil if no non-special characters found at the scan location.
    def scan_text
      pos = self.pos
      return nil unless scanned = self.scan(/[^$#\\]+/)
      Token.new(:text, scanned, @line_number, pos)
    end
    
    def scan_ruby_expression
    end
    
    # Scan a placeholder (a dollar sign followed by an identifier consisting of a string of characters, where legal characters are a to z, lower or uppercase, underscores and decimal digits; like in C the first character must not be a digit). Returns nil if no placeholder found at the scan location. Raises an exception if the placeholder at the scan location is not valid (for example, if it contains no identifier or the identifier contains illegal characters).
    def scan_placeholder
      pos = self.pos
      return nil unless self.match?(/\$/)
      self.scan(/\$[a-zA-Z_][a-zA-Z0-9_]*/) or raise LexerError.new('Invalid or missing placeholder', nil, nil, self.pos)
      self[0] # now contains last match
    
      # Placeholder.new(blah, @line_number, pos)
    end
  
     # Scan an identifier consisting of a string of characters, where legal characters are a to z, lower or uppercase, underscores and decimal digits; like in C the first character must not be a digit. Returns nil if no placeholder found at the scan location.
    def scan_identifier
      pos = self.pos
      return nil unless scanned = self.scan(/[a-zA-Z_][a-zA-Z0-9_]*/)
      Token.new(:identifier, scanned, @line_number, pos)
    end
  
    # Recursion.
    # Parameter parsing is very basic and does not handle the full set of legal Ruby possibilities. It is designed to handle a small number of basic cases as illustratesd in the following examples:
    # 
    #   $example                    no parameters
    #   $example()                  empty parameters
    #   $example(foo)               a ruby expression (a variable)
    #   $example("foo", "bar")      two ruby expressions (string literals)
    #   $example($placeholder)      another placeholder
    #   $example([1, 2, 3], hello)  two ruby expressions (an array and a variable)
    #   $example("hello, foo")      a ruby expression (a string literal with a comma inside it)
    #   $example({}, foo)           two ruby expressions (a hash and a variable)
    #
    # Not sure if I should (or can) allow this kind of nesting
    #
    #   $example([1, 2, $placeholder])
    #
    # ie. a ruby expression (an array) which contains a placeholder
    # i can't see how I would evaluate that at runtime
    # basically, i get a return value from the placeholder, but how do I stick it into the array?
    # it's not internal stored as an array, you see
    # it's stored as a piece of text that contains a ruby expression
    # and that expression is evaluated at runtime
    # if it were a string literal i could just interpolate it, but I have no such guarantees
    # i think I am going to have to disallow such constructs
    #
    # Note that there are several punctation characters that have a higher precedence than the comma; in order:
    #
    #   - ''
    #   - ""
    #   - $     note that placeholders do NOT have any special meaning inside single and double-quoted strings
    #   - ()    note that brackets are ignored if they appear inside quotes
    #   - {}
    #   - []
    #
    # I think I might need two sets of quoted string rules... one for outside of placeholder parameters and one for inside...
    # eg... in text I should be able to just write "foo $bar..."
    # but inside placeholder parameters I that might be ambiguous
    # what is it? a ruby constant string? a ruby constant string with a placeholder stuck inside it runtime etc?
    # the safest way, I think is to not allow placeholders to be embedded in strings inside placeholder parameters
    #
    def scan_placeholder_parameters
      return nil unless self.match?(/\(/)
      pos         = self.pos
      depth       = 1 # keep track of number of left-parentheses seen
      accumulate  = ''
      while depth > 0
        accumulate << self[0] if self.scan(/[^()]+/)
        if self.scan(/\(/)
          depth += 1
          self.scan_placeholder_parameters
        elsif self.scan(/\)/) 
          depth -= 1
        end
      end
    
      # tempting to return a series of tokens here (an array):
      # PlaceholderMarker ($)
      # PlaceholderIdentifier
      # PlaceholderParameterStartDelimiter (left bracket)
      # PlaceholderParameter (could really be anything, including a ruby expression, string literal [which is itself just a subtype of ruby expression] or another placeholder); so here we could declare a subtype or two:
      # => RubyExpression
      # => RubyStringLiteral
      # PlaceholderParameterSeparator (comma)
      # PlaceholderParameterEndDelimiter (right bracket)
      #
      # And in reality, I should probably be doing the same with the directive parser. This will allow me to keep a cleaner separation between the lexer and the parser; by getting the lexer to break the input stream up into more, smaller tokens the complexity of the parser will be kept down:
      # DirectiveMarker (#)
      # DirectiveName
      # Identifier
      # AssignmentTarget
      # AssignmentOperator
      # RubyExpression
      # StringLiteral etc or similar
      #
      # The question remains, how to represent these tokens. Do I really need a different class for each one? Or is there a better way? And if I stick with the existing classes, anyway to make subclassing even more minimal to minimize the work of maintaining so many different classes?
    
    end
    
    def scan_placeholder_parameter
      # scan until you hit an unbalanced right-bracket or a comma outside of the scope of all brackets and strings
      # again, does this need to be recursive? I think it might...
      # what is a placeolder parameter? it can be one of two things:
      # - another placeholder
      # - a ruby expression
      
      bracket_depth         = 0 # count how many normal left brackets seen so far
      square_bracket_depth  = 0 # count how many square left brackets seen so far
      curly_bracket_depth   = 0 # count how many curly left brackets seen so far
      
      in_double_quoted_string = false
      in_single_quoted_string = false
      
      # scan characters which have no special meaning
      #self.scan(/[^\[\](){}"']/)
      
      
      closest = self.closest(['$', '(', ')', '[', ']', '{', '}', '"', "'", ','])
      if closest.nil?
      elsif closest == '$'
      elsif closest == ''
      end
      
    end
    
    # Scan a comment (two consecutive hash symbols). Comments extend from the initial hash symbols to the end of the line on which they appear. This method returns nil if no comment is found at the scan location.
    def scan_comment
      pos = self.pos
      return nil unless self.scan(/##.*/)
      Token.new(:comment, self[0], @line_number, pos)
    end
  
    # Scan a directive (a hash symbol immediately followed by a keyword consisting of a string of characters; legal characers are a to z, lower or uppercase; optionally followed by one or more comma-separated parameters). Returns nil if no directive found at the scan location. Raises an exception if the placeholder at the scan location is not valid (for example, if it contains no keyword or the keyword contains illegal characters )
    def scan_directive
      return nil unless self.match?(/#/)    # doesn't look like a directive
      return nil if self.match?(/##/)       # is actually a comment
      self.scan(/#([a-zA-Z]+)/) or raise LexerError.new('Invalid or missing directive keyword', nil, nil, self.pos)
      keyword = self[1]
      self.skip(/\s*/)                      # eat optional whitespace
      parameters = self.scan_up_to_comment  # scan optional parameter(s)
    
      Token.new(:directive, keyword, parameters)
    end
  
    # Scan an escape sequence. Returns a Text instance, or nil if no escape sequence found at the scan pointer. Raises if an escape sequence is found but it is invalid or is missing its terminator.
    def scan_escape_sequence
      pos = self.pos
      return nil unless self.match?(/\\/)  # doesn't look like an escape sequnce
      unless sequence = self.scan(/(\\)([$#\\])/)
        raise LexerError.new('Invalid or missing escape sequence terminator', nil, nil, self.pos)
      end
      Token.new(:text, self[2], @line_number, pos)
    end
  
    def scan_quoted_string
      pos = self.pos
      start_char = self.scan(/['"]/) or return nil
      if    start_char == '"'   : special_chars = '"\\'
      elsif start_char == "'"   : special_chars = "'\\"
      end
    
      string_body = start_char.clone
      while true
        if self.scan(/[^#{Regexp.escape(special_chars)}]+/)   # normal (non-special) chars
          string_body << self[0]
        elsif self.scan(/#{start_char}/)                      # end of string
          string_body << start_char
          break
        elsif self.scan(/\\#{start_char}/)                    # escaped start_char
          string_body << self[0]
        elsif self.scan(/./)                                  # other escape sequence, just eat the next character
          string_body << self[0]
        else                                                  # bad, must have hit end of string without encountering end character
          raise LexerError.new('Missing quoted string terminator', nil, nil, self.pos)
        end
      end
      string_body
      # TODO: consider returning a token here instead... @line_number, pos
    end
  
    # This function is not string-literal aware. It blindly scans forward until it hits a comment marker. It is therefore important to only call this method under appropriate conditions. For example, it would not be a good idea to scan forward looking for a comment where there might be intervening string literals which contain comment markers.
    def scan_up_to_comment
      text = ''
      hit_limit = false
      until hit_limit
        if self.scan(/[^#\\]+/)           # first, scan characters which have no special meaning
          text << self[0]
        elsif self.eos?                   # hit end of string
          hit_limit = true
        elsif self.match?(/##/)           # found a comment
          hit_limit = true
        elsif self.match?(/\\/)           # found an escape marker
          self.scan(/\\[$#\\]/) or raise LexerError.new('Invalid or missing escape sequence terminator', nil, nil, self.pos)
          text << self[0] 
        elsif self.scan(/#/)              # found a directive, move on without checking for well-formedness
          text << self[0] 
        end
      end
      text == '' ? nil : text
    
      # for consistency... why does this method return a string when the others return tokens?
      # perhaps the methods which return tokens should include the word "token" somewhere in their names
      # or seeing as I am scanning text, perhaps I should call this "scan text up to comment" and return a Text token
      # not sure
      # so far, the only place i am calling this is when parsing directives (where I scan up to the end of the line, or to a comment, whichever comes first)
    end
  
    def line_number=(number)
      @line_number = (number.clone rescue number)
    end
  
  end # class LineScanner
end # module Walrus
