# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    context 'using a parser state object' do
      
      setup do
        @base_string = 'this is the string to be parsed'
        @state = ParserState.new(@base_string)
      end
      
      specify 'should raise an ArgumentError if initialized with nil' do
        lambda { ParserState.new(nil) }.should_raise ArgumentError
      end
      
      specify 'before parsing has started "remainder" should equal the entire string' do
        @state.remainder.should == @base_string
      end
      
      specify 'before parsing has started "remainder" should equal the entire string (when string is an empty string)' do
        ParserState.new('').remainder.should == ''
      end
      
      specify 'before parsing has started "results" should be empty' do
        @state.results.should_be_empty
      end
      
      specify '"parsed" should complain if passed nil' do
        lambda { @state.parsed(nil) }.should_raise ArgumentError
      end
      
      specify '"skipped" should complain if passed nil' do
        lambda { @state.skipped(nil) }.should_raise ArgumentError
      end
      
      specify '"parsed" should return the remainder of the string' do
        @state.parsed('this is the ').should  == 'string to be parsed'
        @state.parsed('string ').should       == 'to be parsed'
        @state.parsed('to be parsed').should  == ''
      end
      
      specify '"skipped" should return the remainder of the string' do
        @state.skipped('this is the ').should == 'string to be parsed'
        @state.skipped('string ').should      == 'to be parsed'
        @state.skipped('to be parsed').should == ''
      end
      
      specify '"results" should return an unwrapped parsed result (for single results)' do
        @state.parsed('this')
        @state.results.should == 'this'
      end
      
      specify 'skipped substrings should not appear in "results"' do
        @state.skipped('this')
        @state.results.should_be_empty
      end
      
      specify 'should return an array of the parsed results (for multiple results)' do
        @state.parsed('this ')
        @state.parsed('is ')
        @state.results.should == ['this ', 'is ']
      end
      
      specify 'should work when the entire string is consumed in a single operation (using "parsed")' do
        @state.parsed(@base_string).should == ''
        @state.results.should == @base_string
      end
      
      specify 'should work when the entire string is consumed in a single operation (using "skipped")' do
        @state.skipped(@base_string).should == ''
        @state.results.should_be_empty
      end
      
      specify '"parsed" should complain if passed something that doesn\'t respond to the "to_s" message' do
        my_mock = mock('mock_which_does_not_implement_to_s') 
        my_mock.should_receive(:to_s).once.and_raise(NoMethodError) 
        lambda { @state.parsed(my_mock) }.should_raise NoMethodError
      end
      
      specify '"skipped" should complain if passed something that doesn\'t respond to the "to_s" message' do
        my_mock = mock('mock_which_does_not_implement_to_s') 
        my_mock.should_receive(:to_s).once.and_raise(NoMethodError) 
        lambda { @state.skipped(my_mock) }.should_raise NoMethodError
      end
      
      specify 'should be able to mix use of "parsed" and "skipped" methods' do
        
        # first example
        @state.skipped('this is the ').should  == 'string to be parsed'
        @state.results.should_be_empty
        @state.parsed('string ').should       == 'to be parsed'
        @state.results.should == 'string '
        @state.skipped('to be parsed').should  == ''
        @state.results.should == 'string '
        
        # second example (add this test to isolate a bug in another specification)
        state = ParserState.new('foo1...')
        state.skipped('foo').should == '1...'
        state.remainder.should == '1...'
        state.results.should_be_empty
        state.parsed('1').should == '...'
        state.remainder.should == '...'
        state.results.should == '1'
        
      end
      
      specify '"parsed" and "results" methods should work with multi-byte Unicode strings' do
        state = ParserState.new('400€, foo')
        state.remainder.should == '400€, foo'
        state.parsed('40').should == '0€, foo'
        state.results.should == '40'
        
        # this next one was failing only from the command line (retured ", foo")
        # solution was to use the "chars" method under the hood for multibyte character support
        state.parsed('0€, ').should == 'foo'
        
        state.results.should == ['40', '0€, ']
        state.parsed('foo').should == ''
        state.results.should == ['40', '0€, ', 'foo']
      end
      
      specify '"skipped" and "results" methods should work with multi-byte Unicode strings' do
        state = ParserState.new('400€, foo')
        state.remainder.should == '400€, foo'
        state.skipped('4').should == '00€, foo'
        state.results.should_be_empty
        state.parsed('0').should == '0€, foo'
        state.results.should == '0'
        state.skipped('0€, ').should == 'foo'
        state.results.should == '0'
        state.parsed('foo').should == ''
        state.results.should == ['0', 'foo']
      end
      
      specify 'whatever is returned from the "results" method should respond to "omitted"' do
        
        # nil (nothing skipped)
        state = ParserState.new('hello world')
        state.parsed('hello world')
        state.results.omitted.should_be_empty
        
        # String
        state = ParserState.new('hello world')
        state.skipped('hello')
        state.results.omitted.should == 'hello'
        
        # MatchDataWrapper
        'hello' =~ /(\w+)/
        wrapper = MatchDataWrapper.new($~)
        state = ParserState.new('hello world')
        state.skipped(wrapper)
        state.results.omitted.should == 'hello'
        
        # Array
        state = ParserState.new('hello world')
        state.skipped('hello')
        state.parsed(' ')
        state.skipped('world')
        state.results.should == ' '
        state.results.omitted.should == ['hello', 'world']
        
      end
      
    end
    
  end # class Grammar
end # module Walrus
