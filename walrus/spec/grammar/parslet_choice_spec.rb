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
#
# $Id: parslet_choice_spec.rb 192 2007-05-03 09:27:35Z wincent $

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    describe 'using a Parslet Choice' do
      
      before(:each) do
        @p1 = 'foo'.to_parseable
        @p2 = 'bar'.to_parseable
      end
      
      it 'hashes should be the same if initialized with the same parseables' do
        ParsletChoice.new(@p1, @p2).hash.should == ParsletChoice.new(@p1, @p2).hash
        ParsletChoice.new(@p1, @p2).should eql(ParsletChoice.new(@p1, @p2))
      end
      
      it 'hashes should (ideally) be different if initialized with different parseables' do
        ParsletChoice.new(@p1, @p2).hash.should_not == ParsletChoice.new('baz'.to_parseable, 'abc'.to_parseable).hash
        ParsletChoice.new(@p1, @p2).should_not eql(ParsletChoice.new('baz'.to_parseable, 'abc'.to_parseable))
      end
      
      it 'hashes should be different compared to other similar classes even if initialized with the same parseables' do
        ParsletChoice.new(@p1, @p2).hash.should_not == ParsletSequence.new(@p1, @p2).hash
        ParsletChoice.new(@p1, @p2).should_not eql(ParsletSequence.new(@p1, @p2))
      end
      
      it 'should be able to use Parslet Choice instances as keys in a hash' do
        hash = {}
        key1 = ParsletChoice.new(@p1, @p2)
        key2 = ParsletChoice.new('baz'.to_parseable, 'abc'.to_parseable)
        hash[:key1] = 'foo'
        hash[:key2] = 'bar'
        hash[:key1].should == 'foo'
        hash[:key2].should == 'bar'
      end
      
    end
    
  end # class Grammar
end # module Walrus
