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

require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Walrat::ParsletRepetition do
  it 'raises if "parseable" argument is nil' do
    expect do
      Walrat::ParsletRepetition.new nil, 0
    end.to raise_error(ArgumentError, /nil parseable/)
  end

  it 'raises if "min" argument is nil' do
    expect do
      Walrat::ParsletRepetition.new 'foo'.to_parseable, nil
    end.to raise_error(ArgumentError, /nil min/)
  end

  it 'raises if passed nil string for parsing' do
    expect do
      Walrat::ParsletRepetition.new('foo'.to_parseable, 0).parse nil
    end.to raise_error(ArgumentError, /nil string/)
  end

  it 'should be able to match "zero or more" times (like "*" in regular expressions)' do
    parslet = Walrat::ParsletRepetition.new 'foo'.to_parseable, 0
    expect do
      parslet.parse 'bar'
    end.to throw_symbol(:ZeroWidthParseSuccess)                   # zero times
    parslet.parse('foo').should == 'foo'                          # one time
    parslet.parse('foofoo').should == ['foo', 'foo']              # two times
    parslet.parse('foofoofoobar').should == ['foo', 'foo', 'foo'] # three times
  end

  it 'should be able to match "zero or one" times (like "?" in regular expressions)' do
    parslet = Walrat::ParsletRepetition.new 'foo'.to_parseable, 0, 1
    expect do
      parslet.parse 'bar'
    end.to throw_symbol(:ZeroWidthParseSuccess) # zero times
    parslet.parse('foo').should == 'foo'        # one time
    parslet.parse('foofoo').should == 'foo'     # stop at one time
  end

  it 'should be able to match "one or more" times (like "+" in regular expressions)' do
    parslet = Walrat::ParsletRepetition.new 'foo'.to_parseable, 1
    expect do
      parslet.parse 'bar'
    end.to raise_error(Walrat::ParseError)                        # zero times (error)
    parslet.parse('foo').should == 'foo'                          # one time
    parslet.parse('foofoo').should == ['foo', 'foo']              # two times
    parslet.parse('foofoofoobar').should == ['foo', 'foo', 'foo'] # three times
  end

  it 'should be able to match "between X and Y" times (like {X, Y} in regular expressions)' do
    parslet = Walrat::ParsletRepetition.new 'foo'.to_parseable, 2, 3
    expect do
      parslet.parse 'bar'
    end.to raise_error(Walrat::ParseError)                        # zero times (error)
    expect do
      parslet.parse 'foo'
    end.to raise_error(Walrat::ParseError)                        # one time (error)
    parslet.parse('foofoo').should == ['foo', 'foo']              # two times
    parslet.parse('foofoofoo').should == ['foo', 'foo', 'foo']    # three times
    parslet.parse('foofoofoofoo').should == ['foo', 'foo', 'foo'] # stop at three times
  end

  it 'matches should be greedy' do
    # here the ParsletRepetition should consume all the "foos", leaving nothing
    # for the final parslet
    parslet = Walrat::ParsletRepetition.new('foo'.to_parseable, 1) & 'foo'
    expect do
      parslet.parse 'foofoofoofoo'
    end.to raise_error(Walrat::ParseError)
  end

  it 'should be able to compare for equality' do
    Walrat::ParsletRepetition.new('foo'.to_parseable, 1).
      should eql(Walrat::ParsletRepetition.new('foo'.to_parseable, 1))
    Walrat::ParsletRepetition.new('foo'.to_parseable, 1).
      should_not eql(Walrat::ParsletRepetition.new('bar'.to_parseable, 1))
    Walrat::ParsletRepetition.new('foo'.to_parseable, 1).
      should_not eql(Walrat::ParsletRepetition.new('foo'.to_parseable, 2))
  end
end
