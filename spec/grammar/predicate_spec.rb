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
    
    autoload(:AndPredicate, 'walrus/grammar/and_predicate')
    autoload(:NotPredicate, 'walrus/grammar/not_predicate')
    
    describe 'using a predicate' do
      
      it 'should raise an ArgumentError if initialized with nil' do
        lambda { Predicate.new(nil) }.should raise_error(ArgumentError)
      end
      
      it 'should complain if sent "parse" message (Predicate abstract superclass, "parse" is the responsibility of the subclasses)' do
        lambda { Predicate.new('foo').parse('bar') }.should raise_error(NotImplementedError)
      end
      
      it 'should be able to compare predicates for equality' do
        Predicate.new('foo').should eql(Predicate.new('foo'))
        Predicate.new('foo').should_not eql(Predicate.new('bar'))
      end
      
      it '"and" and "not" predicates should yield different hashes even if initialized with the same "parseable"' do
        
        parseable = 'foo'.to_parseable
        p1 = Predicate.new(parseable)
        p2 = AndPredicate.new(parseable)
        p3 = NotPredicate.new(parseable)
        
        p1.hash.should_not == p2.hash
        p2.hash.should_not == p3.hash
        p3.hash.should_not == p1.hash
        
        p1.should_not eql(p2)
        p2.should_not eql(p3)
        p3.should_not eql(p1)
        
      end
      
      
    end
    
  end # class Grammar
end # module Walrus
