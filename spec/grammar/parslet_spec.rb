# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

require 'walrus/grammar/parslet'

module Walrus
  class Grammar
    
    context 'using a parslet' do
      
      specify 'should complain if sent "parse" message (Parslet is an abstract superclass, "parse" is the responsibility of the subclasses)' do
        lambda { Parslet.new.parse('bar') }.should_raise NotImplementedError
      end
      
    end
    
  end # class Grammar
end # module Walrus
