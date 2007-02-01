# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

require 'walrus/grammar/predicate'

module Walrus
  class Grammar
    
    context 'using a predicate' do
      
      specify 'should raise an ArgumentError if initialized with nil' do
        lambda { Predicate.new(nil) }.should_raise ArgumentError
      end
      
    end
    
  end # class Grammar
end # module Walrus
