# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), 'spec_helper.rb')

require 'walrus/parser'

module Walrus
  
  context 'parsing with the parser' do
    
    context_setup do
      @parser = Parser.new()
    end
    
    specify 'should be able to instantiate the parser' do
      @parser.should_not_be_nil
    end
    
    specify 'should be able to parse a plaintext string' do
      
    end
  end
  
end # module Walrus

