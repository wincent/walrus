# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    context 'using a string enumerator' do
      
      specify 'should raise an ArgumentError if initialized with nil' do
        lambda { StringEnumerator.new(nil) }.should_raise ArgumentError
      end
      
      specify 'should return characters one by one until end of string, then return nil' do
        enumerator = StringEnumerator.new('hello')
        enumerator.next.should == 'h'
        enumerator.next.should == 'e'
        enumerator.next.should == 'l'
        enumerator.next.should == 'l'
        enumerator.next.should == 'o'
        enumerator.next.should_be_nil
      end
      
      specify 'enumerators should be Unicode-aware (UTF-8)' do
        enumerator = StringEnumerator.new('€ cañon')
        enumerator.next.should == '€'
        enumerator.next.should == ' '
        enumerator.next.should == 'c'
        enumerator.next.should == 'a'
        enumerator.next.should == 'ñ'
        enumerator.next.should == 'o'
        enumerator.next.should == 'n'
        enumerator.next.should_be_nil
      end
      
      # this was a bug
      specify 'enumerators should continue past newlines' do
        enumerator = StringEnumerator.new("hello\nworld")
        enumerator.next.should == 'h'
        enumerator.next.should == 'e'
        enumerator.next.should == 'l'
        enumerator.next.should == 'l'
        enumerator.next.should == 'o'
        enumerator.next.should == "\n" # was returning nil here
        enumerator.next.should == 'w'
        enumerator.next.should == 'o'
        enumerator.next.should == 'r'
        enumerator.next.should == 'l'
        enumerator.next.should == 'd'
      end
      
      specify 'should be able to peek at the next character without actually enumerating' do
        enumerator = StringEnumerator.new('h€llo')
        enumerator.peek.should == 'h' # peek but don't advance
        enumerator.next.should == 'h' # advance
        enumerator.peek.should == '€' # peek a multi-byte character
        enumerator.next.should == '€' # advance a multi-byte character
        enumerator.peek.should == 'l' # peek
        enumerator.peek.should == 'l' # peek the same character again
        enumerator.next.should == 'l' # advance
        enumerator.next.should == 'l' # advance
        enumerator.next.should == 'o' # advance
        enumerator.peek.should == nil # at end should return nil
        enumerator.next.should == nil # nothing left to scan
      end
      
      specify 'should be able to recall the last character using the "last" method' do
        enumerator = StringEnumerator.new('h€llo')
        enumerator.last.should == nil # nothing scanned yet
        enumerator.next.should == 'h' # advance
        enumerator.last.should == nil # still no previous character
        enumerator.next.should == '€' # advance
        enumerator.last.should == 'h'
        enumerator.next.should == 'l' # advance
        enumerator.last.should == '€'
        enumerator.next.should == 'l' # advance
        enumerator.last.should == 'l'
        enumerator.next.should == 'o' # advance
        enumerator.last.should == 'l'
        enumerator.next.should == nil # nothing left to scan
        enumerator.last.should == 'o'
        enumerator.last.should == 'o' # didn't advance, so should return the same as last time
      end
      
    end
    
  end # class Grammar
end # module Walrus
