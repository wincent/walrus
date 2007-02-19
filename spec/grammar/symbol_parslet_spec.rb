# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    context 'using a symbol parslet' do
      
      specify 'should raise an ArgumentError if initialized with nil' do
        lambda { SymbolParslet.new(nil) }.should_raise ArgumentError
      end
      
      specify 'should be able to compare symbol parslets for equality' do
        :foo.to_parseable.should_eql :foo.to_parseable           # equal
        :foo.to_parseable.should_not_eql :bar.to_parseable    # different
        :foo.to_parseable.should_not_eql :Foo.to_parseable    # differing only in case
        :foo.to_parseable.should_not_eql /foo/                # totally different classes
      end
      
    end
    
  end # class Grammar
end # module Walrus
