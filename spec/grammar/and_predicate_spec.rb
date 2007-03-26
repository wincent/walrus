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
    
    context 'using an "and predicate"' do
      
      specify 'should complain on trying to parse a nil string' do
        lambda { AndPredicate.new('irrelevant').parse(nil) }.should_raise ArgumentError
      end
      
      specify 'should be able to compare for equality' do
        AndPredicate.new('foo').should_eql AndPredicate.new('foo')      # same
        AndPredicate.new('foo').should_not_eql AndPredicate.new('bar')  # different
        AndPredicate.new('foo').should_not_eql Predicate.new('foo')     # same, but different classes
      end
      
    end
    
  end # class Grammar
end # module Walrus
