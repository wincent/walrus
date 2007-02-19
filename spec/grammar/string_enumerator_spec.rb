# Copyright 2007 Wincent Colaiuta
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
      
    end
    
  end # class Grammar
end # module Walrus
