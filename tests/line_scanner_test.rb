# Copyright 2007 Wincent Colaiuta
# $Id$

require 'test_helper'
require 'walrus/line_scanner'
require 'walrus/token'

module Walrus
  
  # Tests for LineScanner class
  class LineScannerTest < Test::Unit::TestCase
  
    def test_raise_on_multiline_input
      assert_raise ArgumentError do
        LineScanner.new("foo\n")
      end
      assert_raise ArgumentError do
        LineScanner.new("bar\r")
      end
    end
  
    def test_optional_line_number_parameter
    
      # without optional parameter
      scanner = LineScanner.new('foobar')
      assert_nil scanner.line_number
    
      # with optional parameter
      scanner = LineScanner.new('foobar', 5)
      assert_equal 5, scanner.line_number
    
    end
  
    def test_scan_directive_returns_nil_if_no_text
      assert_nil LineScanner.new("").scan_directive
    end
  
    def test_scan_directive_returns_nil_if_no_valid_directive_text
      assert_nil LineScanner.new("## a comment is not a valid directive").scan_directive
      assert_nil LineScanner.new("Normal text isn't either").scan_directive
      assert_nil LineScanner.new("$neither_is_a_placeholder").scan_directive
    end
  
    def test_scan_directive_without_parameter
      directive = LineScanner.new("#super").scan_directive
      assert_not_nil directive
      assert_kind_of Token, directive
      assert_equal :directive, directive.type
      assert_equal 'super', directive.value_for_key(:directive_string)
      assert_nil directive.value_for_key(:parameter_string)
      
      directive = LineScanner.new("#def").scan_directive
      assert_not_nil directive
      assert_kind_of Token, directive
      assert_equal :directive, directive.type
      assert_equal 'def', directive.value_for_key(:directive_string)
    
      # note that the scanner doesn't check the validity of the token (here we have a missing parameter)
      assert_nil directive.parameter_string
    end
  
    def test_scan_directive_with_parameter
      directive = LineScanner.new("#block body").scan_directive
      assert_not_nil directive
      assert_kind_of Token, directive
      assert_equal :directive, directive.type
      assert_equal 'block', directive.value_for_key(:directive_string)
      assert_equal 'body', directive.value_for_key(:parameter_string)
    end
  
    def test_scan_directive_ignores_whitespace
      directive = LineScanner.new("#block  \t  body").scan_directive
      assert_not_nil directive
      assert_kind_of Token, directive
      assert_equal :directive, directive.type
      assert_equal 'block', directive.value_for_key(:directive_string)
      assert_equal 'body', directive.value_for_key(:parameter_string)
    end
  
    def test_scan_directive_stops_at_comments
  
      scanner = LineScanner.new("#extends basic ## <-- the basic layout")
      directive = scanner.scan_directive
      assert_not_nil directive
      assert_kind_of Token, directive
      assert_equal :directive, directive.type
      assert_equal 'extends', directive.value_for_key(:directive_string)
      assert_equal 'basic ', directive.value_for_key(:parameter_string)
    
      comment = scanner.scan_comment
      assert_not_nil comment
      assert_kind_of Token, comment
      assert_equal :comment, comment.type
      assert_equal '## <-- the basic layout', comment.value_for_key(:comment_string)
    
      scanner = LineScanner.new("#extends basic    ## more whitespace (4) this time")
      directive = scanner.scan_directive
      assert_not_nil directive
      assert_kind_of Token, directive
      assert_equal :directive, directive.type
      assert_equal 'extends', directive.value_for_key(:directive_string)
      assert_equal 'basic    ', directive.value_for_key(:parameter_string)
    
      comment = scanner.scan_comment
      assert_not_nil comment
      assert_kind_of Token, comment
      assert_equal :comment, coment.type
      assert_equal '## more whitespace (4) this time', comment.value_for_key(:comment_string)
    
      scanner = LineScanner.new("#set foo = true ## my comment")
      directive = scanner.scan_directive
      assert_not_nil directive
      assert_kind_of Token, directive
      assert_equal :directive, directive.type
      assert_equal 'set', directive.value_for_key(:directive_string)
      assert_equal 'foo = true ', directive.value_for_key(:parameter_string)
    
      comment = scanner.scan_comment
      assert_not_nil comment
      assert_kind_of Token, comment
      assert_equal :comment, comment.type
      assert_equal '## my comment', comment.value_for_key(:comment_string)
    
    end
  
    def test_scan_directive_complains_about_invalid_escape_sequences
      assert_raise LexerError do
        LineScanner.new("#extends basic \\! invalid").scan_directive
      end
    
      # but valid sequences are ok
      directive = nil
      assert_nothing_raised do
        directive = LineScanner.new("#extends basic \\#valid").scan_directive
      end
      assert_not_nil directive
      assert_kind_of Token, directive
      assert_equal :directive, directive.type
      assert_equal 'extends', directive.value_for_key(:directive_string)
      assert_equal 'basic \\#valid', directive.value_for_key(:parameter_string)
    end
  
    def test_scan_text_returns_nil_if_no_text
      assert_nil LineScanner.new("").scan_text
    end
  
    def test_scan_text_returns_nil_if_no_valid_text
      assert_nil LineScanner.new("## a comment is not a valid Text instance").scan_text
    end
  
    def test_scan_text_returns_only_text
      text = LineScanner.new("foobar... ## comment").scan_text
      assert_kind_of Token, text
      assert_equal :text, text.type
      assert_equal "foobar... ", text.text_string
    
      text = LineScanner.new("foobar... \\\\").scan_text
      assert_equal "foobar... ", text.text_string
    
      text = LineScanner.new("foobar... $placeholder").scan_text
      assert_equal "foobar... ", text.text_string
    end
  
    def test_scan_escape_sequence_returns_nil_if_no_text
      assert_nil LineScanner.new("").scan_escape_sequence
    end
  
    def test_scan_escape_sequence_returns_nil_if_no_sequence
      assert_nil LineScanner.new("text but not an escape sequence").scan_escape_sequence
      assert_nil LineScanner.new("text with escape after... \\$").scan_escape_sequence
    end
  
    def test_scan_escape_sequence_raises_if_invalid_sequence
      assert_raise LexerError do
        LineScanner.new("\\n").scan_escape_sequence
      end
    end
  
    def test_scan_escape_sequence_returns_text
      text = LineScanner.new("\\#").scan_escape_sequence
      assert_kind_of Token, text
      assert_equal :text, text.type
      assert_equal '#', text.text_string
    
      text = LineScanner.new("\\\\").scan_escape_sequence
      assert_equal :text, text.type
      assert_equal '\\', text.text_string
    
      text = LineScanner.new("\\$").scan_escape_sequence
      assert_kind_of Token, text
      assert_equal :text, text.type
      assert_equal '$', text.text_string
    end
  
    def test_scan_placeholder
      # letters and underscores ok
      # numbers ok if not first character
      # TODO: scan placeholder tests
    end
  
    def test_scan_placeholder_parameter
    
      # empty string (no match)
      scanner = LineScanner.new('')
      assert_nil scanner.scan_placeholder_parameter
    
      # a constant string
      scanner = LineScanner.new('"foo"')
      assert_equal '"foo"', scanner.scan_placeholder_parameter
    
      # should stop at first comma
    
      # a constant string (single quotes)
      scanner = LineScanner.new("'foo'")
      assert_equal "'foo'", scanner.scan_placeholder_parameter
    
      # should stop at first comma
    
      # but should ignore commas inside string literals
    
      # should also ignore placeholders inside string literals
    
      # and also ignore walrus directive markers inside string literals
    
      # a Ruby variable
      scanner = LineScanner.new('foo')
      assert_nil 'foo', scanner.scan_placeholder_parameter
    
      # a Ruby array
    
    
      # a Ruby hash
    
      # a simple Ruby expression (two variables being appended to each other)
    
    
      # another placeholder
    
    
      # a placeholder that references another placeholder (recursion)
    
      # should return a placeholder token? (not sure)
    
    
      # a placholder that itself has multiple parameters
    
    
    end
  
    def test_scan_identifier
    
      # empty string (no match)
      scanner = LineScanner.new("")
      assert_nil scanner.scan_identifier
    
      # just a number (no match)
      scanner = LineScanner.new("0")
      assert_nil scanner.scan_identifier
    
      # starting with a number (no match)
      scanner = LineScanner.new("9foo")
      assert_nil scanner.scan_identifier
    
      # lowercase word
      scanner = LineScanner.new("foo")
      identifier = scanner.scan_identifier
      assert identifier.identifier?
      assert_equal "foo", identifier.value_for_key(:identifier_string)
    
      # uppercase word
      scanner = LineScanner.new("FOO")
      identifier = scanner.scan_identifier
      assert identifier.identifier?
      assert_equal "FOO", identifier.value_for_key(:identifier_string)
    
      # mixed-case word
      scanner = LineScanner.new("fOo")
      identifier = scanner.scan_identifier
      assert identifier.identifier?
      assert_equal "fOo", identifier.value_for_key(:identifier_string)
    
      # capital-case word
      scanner = LineScanner.new("Foo")
      identifier = scanner.scan_identifier
      assert identifier.identifier?
      assert_equal "Foo", identifier.value_for_key(:identifier_string)
    
      # word with numbers
      scanner = LineScanner.new("foo1")
      identifier = scanner.scan_identifier
      assert identifier.identifier?
      assert_equal "foo1", identifier.value_for_key(:identifier_string)
    
      # underscore as first character
      scanner = LineScanner.new("_foo")
      identifier = scanner.scan_identifier
      assert identifier.identifier?
      assert_equal "_foo", identifier.value_for_key(:identifier_string)
    
      # underscore as other character
      scanner = LineScanner.new("foo_bar")
      identifier = scanner.scan_identifier
      assert identifier.identifier?
      assert_equal "foo_bar", identifier.value_for_key(:identifier_string)
    
      # single letter
      scanner = LineScanner.new("f")
      identifier = scanner.scan_identifier
      assert identifier.identifier?
      assert_equal "f", identifier.value_for_key(:identifier_string)
    
      # even a single underscore is valid
      scanner = LineScanner.new("_")
      identifier = scanner.scan_identifier
      assert identifier.identifier?
      assert_equal "_", identifier.value_for_key(:identifier_string)
      
      # test that location information is getting correctly propagated through to the identifier token
      scanner = LineScanner.new('not scanned... ident99', 10)
      assert_equal 10, scanner.line_number  # confirm that we really are on line 10
      scanner.pos = 15                      # bump scanner forward, to just before the "ident99"
      identifier = scanner.scan_identifier
      assert identifier.identifier?
      assert_equal 'ident99', identifier.value_for_key(:identifier_string)
      assert_equal 10, identifier.line_number
      assert_equal 15, identifier.column_number
      
    end
  
    def test_scan_up_to_comment
    
      scanner = LineScanner.new("## comment")
      assert_nil scanner.scan_up_to_comment
    
      scanner = LineScanner.new("text... ## comment")
      assert_equal "text... ", scanner.scan_up_to_comment
      assert_nil scanner.scan_up_to_comment
    
      scanner = LineScanner.new("no comment")
      assert_equal "no comment", scanner.scan_up_to_comment
    
      scanner = LineScanner.new("#directive ## comment")
      assert_equal "#directive ", scanner.scan_up_to_comment
    
      scanner = LineScanner.new("text #directive ## comment")
      assert_equal "text #directive ", scanner.scan_up_to_comment
    
      scanner = LineScanner.new("escapes \\#, \\\\ ## comment ")
      assert_equal "escapes \\#, \\\\ ", scanner.scan_up_to_comment
    
    end
  
    def test_scan_quoted_string
    
      # no quotes
      scanner = LineScanner.new('hello')
      assert_nil scanner.scan_quoted_string
    
      # double quotes
      scanner = LineScanner.new('"hello"')
      assert_equal '"hello"', scanner.scan_quoted_string
    
      # single quotes
      scanner = LineScanner.new("'hello'")
      assert_equal "'hello'", scanner.scan_quoted_string
    
      # walrus directive marker should have no meaning inside double quotes
      scanner = LineScanner.new('"foo #bar"')
      assert_equal '"foo #bar"', scanner.scan_quoted_string
    
      # same for single quotes
      scanner = LineScanner.new("'foo #bar'")
      assert_equal "'foo #bar'", scanner.scan_quoted_string
    
      # walrus placeholder marker should have no meaning inside double quotes
      scanner = LineScanner.new('"foo $bar"')
      assert_equal '"foo $bar"', scanner.scan_quoted_string
    
      # same for single quotes
      scanner = LineScanner.new("'foo $bar'")
      assert_equal "'foo $bar'", scanner.scan_quoted_string
    
      # escaped double quotes should be fine
      scanner = LineScanner.new('"foo \\"bar\\""')
      assert_equal '"foo \\"bar\\""', scanner.scan_quoted_string
    
      # escaped single quotes should be fine
      scanner = LineScanner.new("'foo \\'bar\\''")
      assert_equal "'foo \\'bar\\''", scanner.scan_quoted_string
    
      # all other escapes should be silently ignored (passed through)
      scanner = LineScanner.new("'foo \t bar'")
      assert_equal "'foo \t bar'", scanner.scan_quoted_string
    
      # same for single quotes
      scanner = LineScanner.new('"foo \t bar"')
      assert_equal '"foo \t bar"', scanner.scan_quoted_string
    
      # complain if final closing quote not found
      assert_raise LexerError do 
        LineScanner.new('"hello').scan_quoted_string
      end
    
      # same for single quotes
      assert_raise LexerError do 
        LineScanner.new("'hello").scan_quoted_string
      end
      
    end
    
    def test_closest
      
      # raise on nil
      scanner = LineScanner.new('test string')
      assert_raise ArgumentError do
        scanner.closest(nil)
      end
      
      # raise if passed something that isn't enumerable
      assert_raise ArgumentError do
        scanner.closest(/hello/)
      end
        
      # but things like single String objects are enumerable and should be ok
      assert_nothing_raised do
        scanner.closest('nothing')
      end
      
      # return nil if passed empty array
      assert_nil scanner.closest([])
      
      # if passed empty array, position should be unchanged
      assert_equal 0, scanner.pos 
      
      # return nil if no matches
      assert_nil scanner.closest('foobar')              # single String
      assert_nil scanner.closest(['foo', 'bar'])        # Array of Strings
      assert_nil scanner.closest([/[xyz]/])             # Array containing one Regexp
      assert_nil scanner.closest([/[xyz]/, /rodney/])   # Array containing multiple Regexps
      assert_nil scanner.closest(['foobar', /rodney/])  # mixed Array (String and Regexp)
      
      # if no matches found, position should be unchanged
      assert_equal 0, scanner.pos 
      
      # should work with Strings
      assert_equal 'string', scanner.closest('string')
      assert_equal 'string', scanner.closest(['string', 'foo'])
      assert_equal 'string', scanner.closest(['bar', 'string'])
      assert_equal 'test', scanner.closest(['test', 'string'])
      assert_equal 'test', scanner.closest(['string', 'test'])
      
      # and Regexps
      assert_equal /string/, scanner.closest([/string/, /foo/])
      assert_equal /string/, scanner.closest([/bar/, /string/])
      assert_equal /test/, scanner.closest([/test/, /string/])
      assert_equal /test/, scanner.closest([/string/, /test/])
      
      # and mixed arrays of Strings and Regexps
      assert_equal 'string', scanner.closest(['string', /foo/])
      assert_equal 'string', scanner.closest([/bar/, 'string'])
      assert_equal 'test', scanner.closest(['test', /string/])
      assert_equal 'test', scanner.closest([/string/, 'test'])
      
      # same arrays but this time the Strings are Regexps and vice-versa
      assert_equal /string/, scanner.closest([/string/, 'foo'])
      assert_equal /string/, scanner.closest(['bar', /string/])
      assert_equal /test/, scanner.closest([/test/, 'string'])
      assert_equal /test/, scanner.closest(['string', /test/])
      
      # if two or more items match at same distance the first one should be returned
      assert_equal 'test', scanner.closest(['test', /test/, 'test'])
      
      # regular expression characters in Strings have no special meaning
      assert_nil scanner.closest('....')      
      assert_equal /..../, scanner.closest([/..../])
      
    end
  
  end # class LineScannerTest
end # module Walrus