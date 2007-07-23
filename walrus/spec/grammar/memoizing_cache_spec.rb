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
# $Id: memoizing_cache_spec.rb 166 2007-04-09 15:04:40Z wincent $

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    class MemoizingCache
      
      describe 'using the NoValueForKey class' do
        
        it 'NoValueForKey should be a singleton' do
          lambda { NoValueForKey.new }.should raise_error
          NoValueForKey.instance.object_id.should == NoValueForKey.instance.object_id
        end
        
        it 'should be able to use NoValueForKey as the default value for a hash' do
          hash = Hash.new(NoValueForKey.instance)
          hash.default.should == NoValueForKey.instance
          hash[:foo].should == NoValueForKey.instance
          hash[:foo] = 'bar'
          hash[:foo].should == 'bar'
          hash[:bar].should == NoValueForKey.instance
        end
        
      end
      
    end
    
    describe 'using a memoizing cache' do
      
      it 'should be able to parse with memoizing turned on' do
        
      end
      
      it 'should be able to parse with memoizing turned on' do
        
      end
      
      it 'parsing with memoization turned on should be faster' do
        
      end
      
    end
    
    # left-recursion is enabled by code in the memoizer and elsewhere; keep the specs here for want of a better place
    describe 'working with left-recursive rules' do
      
      it 'circular rules should cause a short-circuit' do
        grammar = Grammar.subclass('InfiniteLoop') do
          starting_symbol :a
          rule            :a, :a # a bone-headed rule
        end
        lambda { grammar.parse('anything') }.should raise_error(LeftRecursionException)
      end
      
      it 'shortcuiting should not be fatal if a valid alternative is present' do
        grammar = Grammar.subclass('AlmostInfinite') do
          starting_symbol :a
          rule            :a, :a | :b # slightly less bone-headed
          rule            :b, 'foo'
        end
        grammar.parse('foo').should == 'foo'
      end
      
      it 'should retry after short-circuiting if valid continuation point' do
        
        grammar = Grammar.subclass('MuchMoreRealisticExample') do
          starting_symbol :a
          rule            :a, :a & :b | :b
          rule            :b, 'foo'
        end
        
        # note the right associativity
        grammar.parse('foo').should == 'foo'
        grammar.parse('foofoo').should == ['foo', 'foo']
        grammar.parse('foofoofoo').should == [['foo', 'foo'], 'foo']
        grammar.parse('foofoofoofoo').should == [[['foo', 'foo'], 'foo'], 'foo']
        grammar.parse('foofoofoofoofoo').should == [[[['foo', 'foo'], 'foo'], 'foo'], 'foo']
        
      end
      
      it 'right associativity should work when building AST nodes' do
        
        grammar = Grammar.subclass('RightAssociativeAdditionExample') do
          starting_symbol :addition_expression
          rule            :term, /\d+/
          rule            :addition_expression, :addition_expression & '+'.skip & :term | :term
          production      :addition_expression.build(:node, :left, :right)
          
          # TODO: syntax for expressing alternate production?
          
        end
        
        
        
        
        
        
        
      end
      
    end
    
  end # class Grammar
end # module Walrus
