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

describe Walrat::NotPredicate do
  it 'complains on trying to parse a nil string' do
    expect do
      Walrat::NotPredicate.new('irrelevant').parse nil
    end.to raise_error(ArgumentError, /nil string/)
  end

  it 'can be compared for equality' do
    Walrat::NotPredicate.new('foo').
      should eql(Walrat::NotPredicate.new('foo'))      # same
    Walrat::NotPredicate.new('foo').
      should_not eql(Walrat::NotPredicate.new('bar'))  # different
    Walrat::NotPredicate.new('foo').
      should_not eql(Walrat::Predicate.new('foo'))     # different class
  end
end
