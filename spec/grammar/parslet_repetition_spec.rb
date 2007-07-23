# Copyright 2007 Wincent Colaiuta
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

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    describe 'using a Parslet Repetition' do
      
      it 'should raise if "parseable" argument is nil' do
        lambda { ParsletRepetition.new(nil, 0) }.should raise_error(ArgumentError)
      end
      
      it 'should raise if "min" argument is nil' do
        lambda { ParsletRepetition.new('foo'.to_parseable, nil) }.should raise_error(ArgumentError)
      end
      
      it 'should raise if pass nil string for parsing' do
        lambda { ParsletRepetition.new('foo'.to_parseable, 0).parse(nil) }.should raise_error(ArgumentError)
      end
      
      it 'should be able to match "zero or more" times (like "*" in regular expressions)' do
        parslet = ParsletRepetition.new('foo'.to_parseable, 0)
        lambda { parslet.parse('bar') }.should throw_symbol(:ZeroWidthParseSuccess)   # zero times
        parslet.parse('foo').should == 'foo'                                  # one time
        parslet.parse('foofoo').should == ['foo', 'foo']                      # two times
        parslet.parse('foofoofoobar').should == ['foo', 'foo', 'foo']         # three times
      end
      
      it 'should be able to match "zero or one" times (like "?" in regular expressions)' do
        parslet = ParsletRepetition.new('foo'.to_parseable, 0, 1)
        lambda { parslet.parse('bar') }.should throw_symbol(:ZeroWidthParseSuccess)   # zero times
        parslet.parse('foo').should == 'foo'                                  # one time
        parslet.parse('foofoo').should == 'foo'                               # stop at one time        
      end
      
      it 'should be able to match "one or more" times (like "+" in regular expressions)' do
        parslet = ParsletRepetition.new('foo'.to_parseable, 1)
        lambda { parslet.parse('bar') }.should raise_error(ParseError)        # zero times (error)
        parslet.parse('foo').should == 'foo'                                  # one time
        parslet.parse('foofoo').should == ['foo', 'foo']                      # two times
        parslet.parse('foofoofoobar').should == ['foo', 'foo', 'foo']         # three times
      end
      
      it 'should be able to match "between X and Y" times (like {X, Y} in regular expressions)' do
        parslet = ParsletRepetition.new('foo'.to_parseable, 2, 3)
        lambda { parslet.parse('bar') }.should raise_error(ParseError)        # zero times (error)
        lambda { parslet.parse('foo') }.should raise_error(ParseError)        # one time (error)
        parslet.parse('foofoo').should == ['foo', 'foo']                      # two times
        parslet.parse('foofoofoo').should == ['foo', 'foo', 'foo']            # three times
        parslet.parse('foofoofoofoo').should == ['foo', 'foo', 'foo']         # stop at three times
      end
      
      it 'matches should be greedy' do
        
        # here the ParsletRepetition should consume all the "foos", leaving nothing for the final parslet
        parslet = ParsletRepetition.new('foo'.to_parseable, 1) & 'foo'
        lambda { parslet.parse('foofoofoofoo') }.should raise_error(ParseError)
        
      end
      
      it 'should be able to compare for equality' do
        ParsletRepetition.new('foo'.to_parseable, 1).should eql(ParsletRepetition.new('foo'.to_parseable, 1))
        ParsletRepetition.new('foo'.to_parseable, 1).should_not eql(ParsletRepetition.new('bar'.to_parseable, 1))
        ParsletRepetition.new('foo'.to_parseable, 1).should_not eql(ParsletRepetition.new('foo'.to_parseable, 2))
      end
      
    end
    
  end # class Grammar
end # module Walrus
