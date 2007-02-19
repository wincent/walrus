# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    context 'using a ProcParslet' do
      
      setup do
        @parslet = lambda do |string, options|
          if string == 'foobar' : string
          else                    raise ParseError.new('expected foobar by got "%s"' + string.to_s)
          end
        end.to_parseable
      end
      
      specify 'should raise an ArgumentError if initialized with nil' do
        lambda { ProcParslet.new(nil) }.should_raise ArgumentError
      end
      
      specify 'should complain if asked to parse nil' do
        lambda { @parslet.parse(nil) }.should_raise ArgumentError
      end
      
      specify 'should raise ParseError if unable to parse' do
        lambda { @parslet.parse('bar') }.should_raise ParseError
      end
      
      specify 'should return a parsed value if able to parse' do
        @parslet.parse('foobar').should == 'foobar'
      end
      
      specify 'should be able to compare parslets for equality' do
        
        # in practice only parslets created with the exact same Proc instance will be eql because Proc returns different hashes for each
        @parslet.should_eql @parslet.clone
        @parslet.should_eql @parslet.dup
        @parslet.should_not_eql lambda { nil }.to_parseable
        
      end
      
    end
    
  end # class Grammar
end # module Walrus
