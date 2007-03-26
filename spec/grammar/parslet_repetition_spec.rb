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
    
    context 'using a Parslet Repetition' do
      
      specify 'should raise if "parseable" argument is nil' do
        lambda { ParsletRepetition.new(nil, 0) }.should_raise ArgumentError
      end
      
      specify 'should raise if "min" argument is nil' do
        lambda { ParsletRepetition.new('foo'.to_parseable, nil) }.should_raise ArgumentError
      end
      
      specify 'should raise if pass nil string for parsing' do
        lambda { ParsletRepetition.new('foo'.to_parseable, 0).parse(nil) }.should_raise ArgumentError
      end
      
      specify 'should be able to match "zero or more" times (like "*" in regular expressions)' do
        parslet = ParsletRepetition.new('foo'.to_parseable, 0)
        lambda { parslet.parse('bar') }.should_throw :ZeroWidthParseSuccess   # zero times
        parslet.parse('foo').should == 'foo'                                  # one time
        parslet.parse('foofoo').should == ['foo', 'foo']                      # two times
        parslet.parse('foofoofoobar').should == ['foo', 'foo', 'foo']         # three times
      end
      
      specify 'should be able to match "zero or one" times (like "?" in regular expressions)' do
        parslet = ParsletRepetition.new('foo'.to_parseable, 0, 1)
        lambda { parslet.parse('bar') }.should_throw :ZeroWidthParseSuccess   # zero times
        parslet.parse('foo').should == 'foo'                                  # one time
        parslet.parse('foofoo').should == 'foo'                               # stop at one time        
      end
      
      specify 'should be able to match "one or more" times (like "+" in regular expressions)' do
        parslet = ParsletRepetition.new('foo'.to_parseable, 1)
        lambda { parslet.parse('bar') }.should_raise ParseError               # zero times (error)
        parslet.parse('foo').should == 'foo'                                  # one time
        parslet.parse('foofoo').should == ['foo', 'foo']                      # two times
        parslet.parse('foofoofoobar').should == ['foo', 'foo', 'foo']         # three times
      end
      
      specify 'should be able to match "between X and Y" times (like {X, Y} in regular expressions)' do
        parslet = ParsletRepetition.new('foo'.to_parseable, 2, 3)
        lambda { parslet.parse('bar') }.should_raise ParseError               # zero times (error)
        lambda { parslet.parse('foo') }.should_raise ParseError               # one time (error)
        parslet.parse('foofoo').should == ['foo', 'foo']                      # two times
        parslet.parse('foofoofoo').should == ['foo', 'foo', 'foo']            # three times
        parslet.parse('foofoofoofoo').should == ['foo', 'foo', 'foo']         # stop at three times
      end
      
      specify 'matches should be greedy' do
        
        # here the ParsletRepetition should consume all the "foos", leaving nothing for the final parslet
        parslet = ParsletRepetition.new('foo'.to_parseable, 1) & 'foo'
        lambda { parslet.parse('foofoofoofoo') }.should_raise ParseError
        
      end
      
      specify 'should be able to compare for equality' do
        ParsletRepetition.new('foo'.to_parseable, 1).should_eql ParsletRepetition.new('foo'.to_parseable, 1)
        ParsletRepetition.new('foo'.to_parseable, 1).should_not_eql ParsletRepetition.new('bar'.to_parseable, 1)
        ParsletRepetition.new('foo'.to_parseable, 1).should_not_eql ParsletRepetition.new('foo'.to_parseable, 2)
      end
      
    end
    
  end # class Grammar
end # module Walrus