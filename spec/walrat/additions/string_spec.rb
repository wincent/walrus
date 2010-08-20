#!/usr/bin/env ruby
# encoding: utf-8
# Copyright 2007-2010 Wincent Colaiuta
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

require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe String do
  describe '#to_class_name' do
    it 'works with require names' do
      'foo_bar'.to_class_name.should == 'FooBar'
    end

    it 'works with a single-letter' do
      'f'.to_class_name.should == 'F'
    end

    it 'works with double-underscores' do
      'foo__bar'.to_class_name.should == 'FooBar'
    end

    it 'works with terminating double-underscores' do
      'foo__'.to_class_name.should == 'Foo'
    end
  end
end

describe 'iterating over a string' do
  # formerly a bug: the StringScanner used under the covers was returning nil
  # (stopping) on hitting a newline
  it 'should be able to iterate over strings containing newlines' do
    chars = []
    "hello\nworld".each_char { |c| chars << c }
    chars.should == ['h', 'e', 'l', 'l', 'o', "\n",
      'w', 'o', 'r', 'l', 'd']
  end
end

describe 'working with Unicode strings' do
  before do
    # € (Euro) is a three-byte UTF-8 glyph: "\342\202\254"
    @string = 'Unicode €!'
  end

  it 'the "each_char" method should work with multibyte characters' do
    chars = []
    @string.each_char { |c| chars << c }
    chars.should == ['U', 'n', 'i', 'c', 'o', 'd', 'e', ' ', '€', '!']
  end

  it 'the "chars" method should work with multibyte characters' do
    @string.chars.should == ['U', 'n', 'i', 'c', 'o', 'd', 'e', ' ', '€', '!']
  end

  it 'should be able to use "enumerator" convenience method to get a string enumerator' do
    enumerator = 'hello€'.enumerator
    enumerator.next.should == 'h'
    enumerator.next.should == 'e'
    enumerator.next.should == 'l'
    enumerator.next.should == 'l'
    enumerator.next.should == 'o'
    enumerator.next.should == '€'
    enumerator.next.should be_nil
  end

  it 'the "jlength" method should correctly report the number of characters in a string' do
    @string.jlength.should  == 10
    "€".jlength.should      == 1  # three bytes long, but one character
  end
end

# For more detailed specification of the StringParslet behaviour see
# string_parslet_spec.rb.
describe 'using shorthand to get StringParslets from String instances' do
  it 'chaining two Strings with the "&" operator should yield a two-element sequence' do
    sequence = 'foo' & 'bar'
    sequence.parse('foobar').should == ['foo', 'bar']
    lambda { sequence.parse('no match') }.should raise_error(Walrat::ParseError)
  end

  it 'chaining three Strings with the "&" operator should yield a three-element sequence' do
    sequence = 'foo' & 'bar' & '...'
    sequence.parse('foobar...').should == ['foo', 'bar', '...']
    lambda { sequence.parse('no match') }.should raise_error(Walrat::ParseError)
  end

  it 'alternating two Strings with the "|" operator should yield a single string' do
    sequence = 'foo' | 'bar'
    sequence.parse('foo').should == 'foo'
    sequence.parse('foobar').should == 'foo'
    sequence.parse('bar').should == 'bar'
    lambda { sequence.parse('no match') }.should raise_error(Walrat::ParseError)
  end
end
