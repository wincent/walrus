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

describe Walrat::Predicate do
  it 'raises an ArgumentError if initialized with nil' do
    expect do
      Walrat::Predicate.new nil
    end.to raise_error(ArgumentError, /nil parseable/)
  end

  it 'complains if sent "parse" message' do
    # Predicate abstract superclass, "parse" is the responsibility of the
    # subclasses
    expect do
      Walrat::Predicate.new('foo').parse 'bar'
    end.to raise_error(NotImplementedError)
  end

  it 'should be able to compare predicates for equality' do
    Walrat::Predicate.new('foo').should eql(Walrat::Predicate.new('foo'))
    Walrat::Predicate.new('foo').should_not eql(Walrat::Predicate.new('bar'))
  end

  it '"and" and "not" predicates should yield different hashes even if initialized with the same "parseable"' do
    parseable = 'foo'.to_parseable
    p1 = Walrat::Predicate.new(parseable)
    p2 = Walrat::AndPredicate.new(parseable)
    p3 = Walrat::NotPredicate.new(parseable)

    p1.hash.should_not == p2.hash
    p2.hash.should_not == p3.hash
    p3.hash.should_not == p1.hash

    p1.should_not eql(p2)
    p2.should_not eql(p3)
    p3.should_not eql(p1)
  end
end
