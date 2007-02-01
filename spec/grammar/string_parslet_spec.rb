# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

require 'walrus/grammar/string_parslet'

module Walrus
  class Grammar
    
    context 'using a string parslet' do
      
      setup do
        @parslet = StringParslet.new('HELLO')
      end
      
      specify 'should raise an ArgumentError if initialized with nil' do
        lambda { StringParslet.new(nil) }.should_raise ArgumentError
      end
      
      specify 'parse should succeed if the input string matches' do
        lambda { @parslet.parse('HELLO') }.should_not_raise
      end
      
      specify 'parse should succeed if the input string matches, even if it continues after the match' do
        lambda { @parslet.parse('HELLO...') }.should_not_raise
      end
      
      specify 'parse should return parsed string' do
        @parslet.parse('HELLO').should == 'HELLO'
        @parslet.parse('HELLO...').should == 'HELLO'
      end
      
      specify 'parse should raise an ArgumentError if passed nil' do
        lambda { @parslet.parse(nil) }.should_raise ArgumentError
      end
      
      specify 'parse should raise a ParseError if the input string does not match' do
        lambda { @parslet.parse('GOODBYE') }.should_raise ParseError         # total mismatch
        lambda { @parslet.parse('GOODBYE, HELLO') }.should_raise ParseError  # eventually would match, but too late
        lambda { @parslet.parse('HELL...') }.should_raise ParseError         # starts well, but fails
        lambda { @parslet.parse(' HELLO') }.should_raise ParseError          # note the leading whitespace
        lambda { @parslet.parse('') }.should_raise ParseError                # empty strings can't match
      end
      
      specify 'parse exceptions should include a detailed error message' do
        lambda { @parslet.parse('HELL...') }.should_raise ParseError, 'unexpected character "." (expected "O") while parsing "HELLO"'
        lambda { @parslet.parse('HELL') }.should_raise ParseError, 'unexpected end-of-string (expected "O") while parsing "HELLO"'
      end
      
    end
    
  end # class Grammar
end # module Walrus
