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
    
    describe 'using a Parslet Sequence' do
      
      setup do
        @p1 = 'foo'.to_parseable
        @p2 = 'bar'.to_parseable
      end

      it 'hashes should be the same if initialized with the same parseables' do
        ParsletSequence.new(@p1, @p2).hash.should == ParsletSequence.new(@p1, @p2).hash
        ParsletSequence.new(@p1, @p2).should eql(ParsletSequence.new(@p1, @p2))
      end

      it 'hashes should (ideally) be different if initialized with different parseables' do
        ParsletSequence.new(@p1, @p2).hash.should_not == ParsletSequence.new('baz'.to_parseable, 'abc'.to_parseable).hash
        ParsletSequence.new(@p1, @p2).should_not eql(ParsletSequence.new('baz'.to_parseable, 'abc'.to_parseable))
      end

      it 'hashes should be different compared to other similar classes even if initialized with the same parseables' do
        ParsletSequence.new(@p1, @p2).hash.should_not == ParsletChoice.new(@p1, @p2).hash
        ParsletSequence.new(@p1, @p2).should_not eql(ParsletChoice.new(@p1, @p2))
      end

      it 'should be able to use Parslet Choice instances as keys in a hash' do
        hash = {}
        key1 = ParsletSequence.new(@p1, @p2)
        key2 = ParsletSequence.new('baz'.to_parseable, 'abc'.to_parseable)
        hash[:key1] = 'foo'
        hash[:key2] = 'bar'
        hash[:key1].should == 'foo'
        hash[:key2].should == 'bar'
      end
      
    end
    
  end # class Grammar
end # module Walrus
