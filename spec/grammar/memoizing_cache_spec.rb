# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    class MemoizingCache
      
      context 'using the NoValueForKey class' do
        
        specify 'NoValueForKey should be a singleton' do
          lambda { NoValueForKey.new }.should_raise
          NoValueForKey.instance.object_id.should == NoValueForKey.instance.object_id
        end
        
        specify 'should be able to use NoValueForKey as the default value for a hash' do
          hash = Hash.new(NoValueForKey.instance)
          hash.default.should == NoValueForKey.instance
          hash[:foo].should == NoValueForKey.instance
          hash[:foo] = 'bar'
          hash[:foo].should == 'bar'
          hash[:bar].should == NoValueForKey.instance
        end
        
      end
      
    end
    
    context 'using a memoizing cache' do
      
      specify 'should be able to parse with memoizing turned on' do
        
      end
      
      specify 'should be able to parse with memoizing turned on' do
        
      end
      
      specify 'parsing with memoization turned on should be faster' do
        
      end
      
    end
    
    # left-recursion is enabled by code in the memoizer and elsewhere; keep the specs here for want of a better place
    context 'working with left-recursive rules' do
      
      specify 'circular rules should cause a short-circuit' do
        grammar = Grammar.subclass('InfiniteLoop') do
          starting_symbol :a
          rule            :a, :a # a bone-headed rule
        end
        lambda { grammar.parse('anything') }.should raise_error(LeftRecursionException)
      end
      
      specify 'shortcuiting should not be fatal if a valid alternative is present' do
        grammar = Grammar.subclass('AlmostInfinite') do
          starting_symbol :a
          rule            :a, :a | :b # slightly less bone-headed
          rule            :b, 'foo'
        end
        grammar.parse('foo').should == 'foo'
      end
      
      specify 'should retry after short-circuiting if valid continuation point' do
        
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
      
      specify 'right associativity should work when building AST nodes' do
        
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
