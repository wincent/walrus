# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    autoload(:AndPredicate, 'walrus/grammar/and_predicate')
    autoload(:NotPredicate, 'walrus/grammar/not_predicate')
    
    context 'using a predicate' do
      
      specify 'should raise an ArgumentError if initialized with nil' do
        lambda { Predicate.new(nil) }.should_raise ArgumentError
      end
      
      specify 'should complain if sent "parse" message (Predicate abstract superclass, "parse" is the responsibility of the subclasses)' do
        lambda { Predicate.new('foo').parse('bar') }.should_raise NotImplementedError
      end
      
      specify 'should be able to compare predicates for equality' do
        Predicate.new('foo').should_eql Predicate.new('foo')
        Predicate.new('foo').should_not_eql Predicate.new('bar')
      end
      
      specify '"and" and "not" predicates should yield different hashes even if initialized with the same "parseable"' do
        
        parseable = 'foo'.to_parseable
        p1 = Predicate.new(parseable)
        p2 = AndPredicate.new(parseable)
        p3 = NotPredicate.new(parseable)
        
        p1.hash.should_not == p2.hash
        p2.hash.should_not == p3.hash
        p3.hash.should_not == p1.hash
        
        p1.should_not_eql p2
        p2.should_not_eql p3
        p3.should_not_eql p1
        
      end
      
      
    end
    
  end # class Grammar
end # module Walrus
