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
    
    describe 'working in the default namespace' do
      
      it 'should complain if passed nil as subclass name' do
        lambda { Node.subclass(nil) }.should raise_error(ArgumentError)
      end
      
      it 'should be able to create a Node subclass (default namespace)' do
        
        # passing a string
        Node.subclass('FooNode').should_not be_nil
        FooNode.class.should == Class # meta class
        FooNode.new('blah').class.should == FooNode
        
        # passing a symbol
        Node.subclass(:BarNode).should_not be_nil
        BarNode.class.should == Class # meta class
        BarNode.new('blah').class.should == BarNode
        
      end
      
      it 'should be able to create a Node subclass (explicit namespace, Walrus::Grammar)' do
        
        # default accessor, lexeme
        Node.subclass('ExplicitNamespaceNode', Walrus::Grammar).should_not be_nil
        ExplicitNamespaceNode.new('hi').lexeme.should == 'hi'
        
        # override default accessor
        Node.subclass('ExplicitNamespaceNode2', Walrus::Grammar, :foo).should_not be_nil
        ExplicitNamespaceNode2.new('hi').foo.should == 'hi'
        
        # multiple accessors
        Node.subclass('ExplicitNamespaceNode3', Walrus::Grammar, :foo, :bar).should_not be_nil
        n = ExplicitNamespaceNode3.new('hi', 'world')
        n.foo.should == 'hi'
        n.bar.should == 'world'
        
      end
      
      it 'should be able to create a Node subclass (totally custom namespace)' do
        
        # default accessor, lexeme
        Node.subclass('CustomNamespaceNode', Walrus).should_not be_nil
        CustomNamespaceNode.new('hi').lexeme.should == 'hi'
        
        # override default accessor
        Node.subclass('CustomNamespaceNode2', Walrus, :foo).should_not be_nil
        CustomNamespaceNode2.new('hi').foo.should == 'hi'
        
        # multiple accessors
        Node.subclass('CustomNamespaceNode3', Walrus, :foo, :bar).should_not be_nil
        n = CustomNamespaceNode3.new('hi', 'world')
        n.foo.should == 'hi'
        n.bar.should == 'world'
        
      end
      
      it 'read accessors should work on a Node subclasses' do
        
        # default accessor, lexeme
        Node.subclass('AmazingNode')
        AmazingNode.new('xyz').lexeme.should == 'xyz'
        
        # single custom accessor
        Node.subclass('AmazingerNode', Walrus::Grammar, :foo)
        AmazingerNode.new('bar').foo.should == 'bar'
        
        # two custom accessors
        Node.subclass('AmazingestNode', Walrus::Grammar, :bar, :baz)
        node = AmazingestNode.new('hello', 'world')
        node.bar.should == 'hello'
        node.baz.should == 'world'
        
      end
      
      it 'should complain if initialize called with missing arguments' do
        
        # default accessor, lexeme
        Node.subclass('AmazingNode2')
        lambda { AmazingNode2.new }.should raise_error(ArgumentError)
        
        # single custom accessor
        Node.subclass('AmazingerNode2', Walrus::Grammar, :foo)
        lambda { AmazingerNode2.new }.should raise_error(ArgumentError)
        
        # two custom accessors
        Node.subclass('AmazingestNode2', Walrus::Grammar, :bar, :baz)
        lambda { AmazingestNode2.new }.should raise_error(ArgumentError) # missing both arguments
        lambda { AmazingestNode2.new('hello') }.should raise_error(ArgumentError) # missing one argument
        
      end
      
      it 'should be able to subclass a Node subclass' do
        
        Node.subclass('FirstSubclass')
        FirstSubclass.subclass('Grandchild').should_not be_nil
        Grandchild.new('foo').class.should == Grandchild
        Grandchild.new('hello').lexeme.should == 'hello'
        
      end
      
      it 'read accessors should work on a subclass of a Node subclass' do
        Node.subclass('MySubclass')
        MySubclass.subclass('OtherSubclass', Walrus::Grammar, :from, :to).should_not be_nil
        s = OtherSubclass.new('Bob', 'Alice')
        s.from.should == 'Bob'
        s.to.should == 'Alice'
      end
      
    end
    
  end # class Grammar  
end # module Walrus

