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
    
    context 'using a "not predicate"' do
      
      specify 'should complain on trying to parse a nil string' do
        lambda { NotPredicate.new('irrelevant').parse(nil) }.should raise_error(ArgumentError)
      end
      
      specify 'should be able to compare for equality' do
        NotPredicate.new('foo').should eql(NotPredicate.new('foo'))      # same
        NotPredicate.new('foo').should_not eql(NotPredicate.new('bar'))  # different
        NotPredicate.new('foo').should_not eql(Predicate.new('foo'))     # same, but different classes
      end
      
    end
    
  end # class Grammar
end # module Walrus
