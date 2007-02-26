# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  class WalrusGrammar
    
    context 'producing a Document containing a SilentDirective' do
      
      setup do
        @parser = Parser.new
      end
      
      specify 'should produce no output' do
        
        # simple example
        compiled = @parser.compile("#silent 'foo'", :class_name => :SilentDirectiveSpecAlpha)
        self.class.class_eval(compiled).should == ''
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

