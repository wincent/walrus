# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/additions/strscan'
require 'walrus/token'

module Walrus

  # A tokenizer
  class Lexer
  
    attr_reader :input_text
    attr_reader :tokens
  
    def initialize(input)
      raise ArgumentError.new("Lexer initialized with nil input") if input.nil?
      @input_text = input.clone
      self.lex
    end
  
    def lex
      @tokens = []
      scanner = StringScanner.new(@input_text)
    
      # scan line by line
      @line_number = 0 # for error reporting
      begin
      
        # special case: when scanning #ruby blocks must blindly search until he hit an #end directive
        @ruby_mode = false
      
        while not scanner.eos?
          line = scanner.scan_up_to_eol
          @line_tokens = [] # keep per-line array of tokens as well
          if line.nil?
            @tokens.push(Token.new(:text, '', @line_number, 0)) # empty line
          else
            line_scanner = LineScanner.new(line, @line_number)
          
          
            # TODO: some of these methods might return an array of tokens instead of a single token
            # need to update these things to take that into account
            # two key cases:
            # directives may return mutliple tokens (placeholders etc)
            # placeholders may also return multiple tokens (other placeholders etc; recursion)
          
            while not line_scanner.eos?
              if text = line_scanner.scan_text
                [@tokens, @line_tokens].each { |array| array.push(text) }
              elsif comment = line_scanner.scan_comment
                [@tokens, @line_tokens].each { |array| array.push(comment) }
              elsif directive = line_scanner.scan_directive
                [@tokens, @line_tokens].each { |array| array.push(directive) }
              
                if directive.ruby?
                  # special case for #ruby directive here; switch to ruby mode
                  # (don't want to write a lexer for Ruby, or learn how to use RubyLexer)
                  @ruby_mode = true                
                end
              
              elsif escape_sequence = line_scanner.scan_escape_sequence
                [@tokens, @line_tokens].each { |array| array.push(escape_sequence) }
              elsif placeholder = line_scanner.scan_placeholder
                [@tokens, @line_tokens].each { |array| array.push(placeholder) }
              end
            end
          
          end
  
          # try scanning end-of-line marker
          if eol = scanner.scan_eol # this is a StringScanner method not a LineScanner one; it returns a string, not a token
            
            pos = line ? line.length : 0
            
            # if only other thing on line is comment token, this is a non-printing eol
            if @line_tokens.length == 1 and @line_tokens.first.comment?
              [@tokens, @line_tokens].each { |array| array.push(Token.new(:silent_eol, eol, @line_number, pos)) }
            else
              [@tokens, @line_tokens].each { |array| array.push(Token.new(:eol, eol, @line_number, pos)) }
            end
            
            @line_number += 1
            
          end
        
        end
      rescue LexerError => e
        e.line_number = @line_number
        raise e
      end
      @tokens
    end
  
    def input_text=(input)
      raise ArgumentError.new("Lexer passed nil input") if input.nil?
      @input_text = input
      self.lex
    end
  
  end # class Lexer
end # module Walrus
