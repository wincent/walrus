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
    
    describe 'using an "and predicate"' do
      
      it 'should complain on trying to parse a nil string' do
        lambda { AndPredicate.new('irrelevant').parse(nil) }.should raise_error(ArgumentError)
      end
      
      it 'should be able to compare for equality' do
        AndPredicate.new('foo').should eql(AndPredicate.new('foo'))      # same
        AndPredicate.new('foo').should_not eql(AndPredicate.new('bar'))  # different
        AndPredicate.new('foo').should_not eql(Predicate.new('foo'))     # same, but different classes
      end
      
    end
    
  end # class Grammar
end # module Walrus
