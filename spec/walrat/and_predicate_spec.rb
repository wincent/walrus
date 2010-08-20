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

require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))

describe Walrat::AndPredicate do
  subject { Walrat::AndPredicate.new('foo') }

  it 'complains on trying to parse a nil string' do
    expect do
      subject.parse nil
    end.to raise_error(ArgumentError)
  end

  it 'is able to compare for equality' do
    should eql(Walrat::AndPredicate.new('foo'))     # same
    should_not eql(Walrat::AndPredicate.new('bar')) # different
    should_not eql(Walrat::Predicate.new('foo'))    # same but different class
  end
end
