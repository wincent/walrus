# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

require 'walrus/grammar/and_predicate'

module Walrus
  class Grammar
    
    context 'using an "and predicate"' do
      
      specify 'should complain on trying to parse a nil string' do
        lambda { AndPredicate.new('irrelevant').parse(nil) }.should_raise ArgumentError
      end
      
    end
    
  end # class Grammar
end # module Walrus
