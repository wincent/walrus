# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: string_parslet_spec.rb 192 2007-05-03 09:27:35Z wincent $

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    describe 'using a string parslet' do
      
      before(:each) do
        @parslet = StringParslet.new('HELLO')
      end
      
      it 'should raise an ArgumentError if initialized with nil' do
        lambda { StringParslet.new(nil) }.should raise_error(ArgumentError)
      end
      
      it 'parse should succeed if the input string matches' do
        lambda { @parslet.parse('HELLO') }.should_not raise_error
      end
      
      it 'parse should succeed if the input string matches, even if it continues after the match' do
        lambda { @parslet.parse('HELLO...') }.should_not raise_error
      end
      
      it 'parse should return parsed string' do
        @parslet.parse('HELLO').should == 'HELLO'
        @parslet.parse('HELLO...').should == 'HELLO'
      end
      
      it 'parse should raise an ArgumentError if passed nil' do
        lambda { @parslet.parse(nil) }.should raise_error(ArgumentError)
      end
      
      it 'parse should raise a ParseError if the input string does not match' do
        lambda { @parslet.parse('GOODBYE') }.should raise_error(ParseError)        # total mismatch
        lambda { @parslet.parse('GOODBYE, HELLO') }.should raise_error(ParseError) # eventually would match, but too late
        lambda { @parslet.parse('HELL...') }.should raise_error(ParseError)        # starts well, but fails
        lambda { @parslet.parse(' HELLO') }.should raise_error(ParseError)         # note the leading whitespace
        lambda { @parslet.parse('') }.should raise_error(ParseError)               # empty strings can't match
      end
      
      it 'parse exceptions should include a detailed error message' do
        # TODO: catch the raised exception and compare the message
        lambda { @parslet.parse('HELL...') }.should raise_error(ParseError)
        lambda { @parslet.parse('HELL') }.should raise_error(ParseError)
      end
      
      it 'should be able to compare string parslets for equality' do
        'foo'.to_parseable.should eql('foo'.to_parseable)           # equal
        'foo'.to_parseable.should_not eql('bar'.to_parseable)       # different
        'foo'.to_parseable.should_not eql('Foo'.to_parseable)       # differing only in case
        'foo'.to_parseable.should_not eql(/foo/)                    # totally different classes
      end
      
      it 'should accurately pack line and column ends into whatever is returned by "parse"' do
        
        # single word
        parslet = 'hello'.to_parseable
        result = parslet.parse('hello')
        result.line_end.should == 0
        result.column_end.should == 5
        
        # single word with newline at end (UNIX style)
        parslet = "hello\n".to_parseable
        result = parslet.parse("hello\n")
        result.line_end.should == 1
        result.column_end.should == 0
        
        # single word with newline at end (Classic Mac style)
        parslet = "hello\r".to_parseable
        result = parslet.parse("hello\r")
        result.line_end.should == 1
        result.column_end.should == 0
        
        # single word with newline at end (Windows style)
        parslet = "hello\r\n".to_parseable
        result = parslet.parse("hello\r\n")
        result.line_end.should == 1
        result.column_end.should == 0
        
        # two lines (UNIX style)
        parslet = "hello\nworld".to_parseable
        result = parslet.parse("hello\nworld")
        result.line_end.should == 1
        result.column_end.should == 5
        
        # two lines (Classic Mac style)
        parslet = "hello\rworld".to_parseable
        result = parslet.parse("hello\rworld")
        result.line_end.should == 1
        result.column_end.should == 5
        
        # two lines (Windows style)
        parslet = "hello\r\nworld".to_parseable
        result = parslet.parse("hello\r\nworld")
        result.line_end.should == 1
        result.column_end.should == 5
        
      end
      
      it 'line and column end should reflect last succesfully scanned position prior to failure' do
        
        # fail right at start
        parslet = "hello\r\nworld".to_parseable
        begin
          parslet.parse('foobar')
        rescue ParseError => e
          exception = e
        end
        exception.line_end.should == 0
        exception.column_end.should == 0
        
        # fail after 1 character
        begin
          parslet.parse('hfoobar')
        rescue ParseError => e
          exception = e
        end
        exception.line_end.should == 0
        exception.column_end.should == 1
        
        # fail after end-of-line
        begin
          parslet.parse("hello\r\nfoobar")
        rescue ParseError => e
          exception = e
        end
        exception.line_end.should == 1
        exception.column_end.should == 0
        
      end
      
    end
    
  end # class Grammar
end # module Walrus
