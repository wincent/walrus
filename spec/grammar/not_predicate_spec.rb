# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

require 'walrus/grammar/not_predicate'

module Walrus
  class Grammar
    
    context 'using a "not predicate"' do
      
      specify 'should complain on trying to parse a nil string' do
        lambda { NotPredicate.new('irrelevant').parse(nil) }.should_raise ArgumentError
      end
      
      specify 'should be able to compare for equality' do
        NotPredicate.new('foo').should_eql NotPredicate.new('foo')      # same
        NotPredicate.new('foo').should_not_eql NotPredicate.new('bar')  # different
        NotPredicate.new('foo').should_not_eql Predicate.new('foo')     # same, but different classes
      end
      
    end
    
  end # class Grammar
end # module Walrus
