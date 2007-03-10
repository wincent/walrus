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
    
    context 'working with left-recursive rules' do
      
      specify 'self-referencing rules should go into an infinite loop' do
        
        grammar = Grammar.subclass('InfiniteLoop') do
          starting_symbol :a
          rule            :a, :a # a bone-headed rule
        end
        lambda { grammar.parse('anything')}.should raise_error(LeftRecursionException)
        
      end
      
    end
    
  end # class Grammar
end # module Walrus
