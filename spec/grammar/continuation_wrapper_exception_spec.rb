# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

require 'walrus/grammar/continuation_wrapper_exception'

module Walrus
  class Grammar
    
    context 'creating a continuation wrapper exception' do
      
      specify 'should complain if initialized with nil' do
        lambda { ContinuationWrapperException.new(nil) }.should_raise ArgumentError
      end
      
    end
    
  end # class Grammar
end # module Walrus
