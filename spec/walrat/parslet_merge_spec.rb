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

describe Walrat::ParsletMerge do
  it 'should be able to compare for equality' do
    Walrat::ParsletMerge.new('foo', 'bar').should eql(Walrat::ParsletMerge.new('foo', 'bar'))
    Walrat::ParsletMerge.new('foo', 'bar').should_not eql(Walrat::ParsletOmission.new('foo')) # wrong class
  end

  it 'ParsletMerge and ParsletSequence hashs should not match even if created using the same parseable instances' do
    parseable1 = 'foo'.to_parseable
    parseable2 = 'bar'.to_parseable
    p1 = Walrat::ParsletMerge.new(parseable1, parseable2)
    p2 = Walrat::ParsletSequence.new(parseable1, parseable2)
    p1.hash.should_not == p2.hash
    p1.should_not eql(p2)
  end
end
