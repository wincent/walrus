# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  
  class WalrusGrammar
    
    context 'compiling a comment instance' do
      
      specify 'comments should produce no meaningful output' do
        self.class.class_eval(MultilineComment.new(" hello\n   world ").compile).should == nil
      end
      
    end
    
    context 'producing a Document containing Comment' do
      
      setup do
        @parser = Parser.new
      end
      
      specify 'should produce no output' do
        
        # simple multiline comment
        comment = @parser.compile("#* hello\n   world *#", :class_name => :MultilineCommentSpecAlpha)
        self.class.class_eval(comment).should == ''
        
        # nested singleline comment
        comment = @parser.compile("#* hello ## <-- first line\n   world *#", :class_name => :MultilineCommentSpecBeta)
        self.class.class_eval(comment).should == ''
        
        # nested multiline comment
        comment = @parser.compile("#* hello ## <-- first line\n   world #* <-- second line *# *#", :class_name => :MultilineCommentSpecDelta)
        self.class.class_eval(comment).should == ''
        
        # multiple comments
        comment = @parser.compile("#* hello *##* world *#", :class_name => :MultilineCommentSpecGamma)
        self.class.class_eval(comment).should == ''
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

