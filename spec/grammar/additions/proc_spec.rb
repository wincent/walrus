# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    context 'work with Proc instances' do
      
      specify 'should respond to "to_parseable", "parse" and "memoizing_parse"' do
        proc = lambda { |string, options| 'foo' }.to_parseable
        proc.parse('bar').should == 'foo'
        proc.memoizing_parse('bar').should == 'foo'
      end
      
    end
    
  end # class Grammar
end # module Walrus