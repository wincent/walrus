# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

require 'walrus/grammar/additions/string'

module Walrus
  class Grammar
    
    context 'working with unicode strings' do
      
      setup do
        @string = 'Unicode €!' # € (Euro) is a three-byte UTF-8 glyph: "\342\202\254"
      end
      
      specify 'the "each_char" method should work with multibyte characters' do
        chars = []
        @string.each_char { |c| chars << c }
        chars.length.should == 10
        chars[0].should == 'U'
        chars[1].should == 'n'
        chars[2].should == 'i'
        chars[3].should == 'c'
        chars[4].should == 'o'
        chars[5].should == 'd'
        chars[6].should == 'e'
        chars[7].should == ' '
        chars[8].should == '€'
        chars[9].should == '!'
      end
      
      specify 'the "chars" method should work with multibyte characters' do
        @string.chars.should == ['U', 'n', 'i', 'c', 'o', 'd', 'e', ' ', '€', '!']
      end
      
      specify 'should be able to use "enumerator" convenience method to get a string enumerator' do
        enumerator = 'hello€'.enumerator
        enumerator.next.should == 'h'
        enumerator.next.should == 'e'
        enumerator.next.should == 'l'
        enumerator.next.should == 'l'
        enumerator.next.should == 'o'
        enumerator.next.should == '€'
        enumerator.next.should_be_nil
      end
      
      specify 'the "length" method should correctly report the number of characters in a string' do
        @string.length.should == 10
        "€".length.should     == 1  # three bytes long, but one character
      end
      
    end
    
    # For more detailed specification of the StringParslet behaviour see string_parslet_spec.rb.
    context 'using shorthand to get StringParslets from String instances' do
      
      specify 'chaining two Strings with the "&" operator should yield a two-element sequence' do
        sequence = 'foo' & 'bar'
        sequence.parse('foobar').should == ['foo', 'bar']
        lambda { sequence.parse('no match') }.should_raise ParseError
      end
      
      specify 'chaining three Strings with the "&" operator should yield a three-element sequence' do
        sequence = 'foo' & 'bar' & '...'
        sequence.parse('foobar...').should == ['foo', 'bar', '...']
        lambda { sequence.parse('no match') }.should_raise ParseError
      end
      
      specify 'alternating two Strings with the "|" operator should yield a single string' do
        sequence = 'foo' | 'bar'
        sequence.parse('foo').should == 'foo'
        sequence.parse('foobar').should == 'foo'
        sequence.parse('bar').should == 'bar'
        lambda { sequence.parse('no match') }.should_raise ParseError
      end
      
    end
  
  end # class Grammar
end # module Walrus
