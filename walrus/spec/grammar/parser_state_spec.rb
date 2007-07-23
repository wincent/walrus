# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: parser_state_spec.rb 192 2007-05-03 09:27:35Z wincent $

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    describe 'using a parser state object' do
      
      before(:each) do
        @base_string = 'this is the string to be parsed'
        @state = ParserState.new(@base_string)
      end
      
      it 'should raise an ArgumentError if initialized with nil' do
        lambda { ParserState.new(nil) }.should raise_error(ArgumentError)
      end
      
      it 'before parsing has started "remainder" should equal the entire string' do
        @state.remainder.should == @base_string
      end
      
      it 'before parsing has started "remainder" should equal the entire string (when string is an empty string)' do
        ParserState.new('').remainder.should == ''
      end
      
      it 'before parsing has started "results" should be empty' do
        @state.results.should be_empty
      end
      
      it '"parsed" should complain if passed nil' do
        lambda { @state.parsed(nil) }.should raise_error(ArgumentError)
      end
      
      it '"skipped" should complain if passed nil' do
        lambda { @state.skipped(nil) }.should raise_error(ArgumentError)
      end
      
      it '"parsed" should return the remainder of the string' do
        @state.parsed('this is the ').should  == 'string to be parsed'
        @state.parsed('string ').should       == 'to be parsed'
        @state.parsed('to be parsed').should  == ''
      end
      
      it '"skipped" should return the remainder of the string' do
        @state.skipped('this is the ').should == 'string to be parsed'
        @state.skipped('string ').should      == 'to be parsed'
        @state.skipped('to be parsed').should == ''
      end
      
      it '"results" should return an unwrapped parsed result (for single results)' do
        @state.parsed('this')
        @state.results.should == 'this'
      end
      
      it 'skipped substrings should not appear in "results"' do
        @state.skipped('this')
        @state.results.should be_empty
      end
      
      it 'should return an array of the parsed results (for multiple results)' do
        @state.parsed('this ')
        @state.parsed('is ')
        @state.results.should == ['this ', 'is ']
      end
      
      it 'should work when the entire string is consumed in a single operation (using "parsed")' do
        @state.parsed(@base_string).should == ''
        @state.results.should == @base_string
      end
      
      it 'should work when the entire string is consumed in a single operation (using "skipped")' do
        @state.skipped(@base_string).should == ''
        @state.results.should be_empty
      end
      
      it '"parsed" should complain if passed something that doesn\'t respond to the "line_end" and "column_end" messages' do
        
        # line_end
        my_mock = mock('mock_which_does_not_implement_line_end', :null_object => true) 
        my_mock.should_receive(:line_end).and_raise(NoMethodError) 
        lambda { @state.parsed(my_mock) }.should raise_error(NoMethodError)
        
        # column_end
        my_mock = mock('mock_which_does_not_implement_column_end', :null_object => true) 
        my_mock.should_receive(:column_end).and_raise(NoMethodError) 
        lambda { @state.parsed(my_mock) }.should raise_error(NoMethodError)
        
      end
      
      it '"skipped" should complain if passed something that doesn\'t respond to the "line_end" and "column_end" messages' do
        
        # line_end
        my_mock = mock('mock_which_does_not_implement_line_end', :null_object => true) 
        my_mock.should_receive(:line_end).and_raise(NoMethodError) 
        lambda { @state.skipped(my_mock) }.should raise_error(NoMethodError)
        
        # column_end
        my_mock = mock('mock_which_does_not_implement_column_end', :null_object => true) 
        my_mock.should_receive(:column_end).and_raise(NoMethodError) 
        lambda { @state.skipped(my_mock) }.should raise_error(NoMethodError)
        
      end
      
      it 'should be able to mix use of "parsed" and "skipped" methods' do
        
        # first example
        @state.skipped('this is the ').should  == 'string to be parsed'
        @state.results.should be_empty
        @state.parsed('string ').should       == 'to be parsed'
        @state.results.should == 'string '
        @state.skipped('to be parsed').should  == ''
        @state.results.should == 'string '
        
        # second example (add this test to isolate a bug in another specification)
        state = ParserState.new('foo1...')
        state.skipped('foo').should == '1...'
        state.remainder.should == '1...'
        state.results.should be_empty
        state.parsed('1').should == '...'
        state.remainder.should == '...'
        state.results.should == '1'
        
      end
      
      it '"parsed" and "results" methods should work with multi-byte Unicode strings' do
        
        # basic test
        state = ParserState.new('400€, foo')
        state.remainder.should == '400€, foo'
        state.parsed('40').should == '0€, foo'
        state.results.should == '40'
        state.parsed('0€, ').should == 'foo'
        state.results.should == ['40', '0€, ']
        state.parsed('foo').should == ''
        state.results.should == ['40', '0€, ', 'foo']
        
        # test with newlines before and after multi-byte chars
        state = ParserState.new("400\n or more €...\nfoo")
        state.remainder.should == "400\n or more €...\nfoo"
        state.parsed("400\n or more").should == " €...\nfoo"
        state.results.should == "400\n or more"
        state.parsed(' €..').should == ".\nfoo"
        state.results.should == ["400\n or more", ' €..']
        state.parsed(".\nfoo").should == ''
        state.results.should == ["400\n or more", ' €..', ".\nfoo"]
        
      end
      
      it '"skipped" and "results" methods should work with multi-byte Unicode strings' do
        state = ParserState.new('400€, foo')
        state.remainder.should == '400€, foo'
        state.skipped('4').should == '00€, foo'
        state.results.should be_empty
        state.parsed('0').should == '0€, foo'
        state.results.should == '0'
        state.skipped('0€, ').should == 'foo'
        state.results.should == '0'
        state.parsed('foo').should == ''
        state.results.should == ['0', 'foo']
      end
      
    end
    
  end # class Grammar
end # module Walrus
