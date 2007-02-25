# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), 'spec_helper.rb')

module Walrus
  
  context 'using the Compiler class' do
    
    context_setup do
      @parser = Parser.new
    end
    
    specify 'should be able to compile a comment followed by raw text' do
      
      # note that trailing newline is eaten when the comment is the only thing on the newline
      compiled = @parser.compile("## hello world\nhere's some raw text", :class_name => :CompilerSpecAlpha)
      eval(compiled).should == "here's some raw text"
      
    end
    
    specify 'should be able to compile raw text followed by a comment' do
      
      # on the same line (note that trailing newline is not eaten)
      compiled = @parser.compile("here's some raw text## hello world\n", :class_name => :CompilerSpecBeta)
      eval(compiled).should == "here's some raw text\n"
      
      # on two separate lines (note that second trailing newline gets eaten)
      compiled = @parser.compile("here's some raw text\n## hello world\n", :class_name => :CompilerSpecDelta)
      eval(compiled).should == "here's some raw text\n"
      
      # same but with no trailing newline
      compiled = @parser.compile("here's some raw text\n## hello world", :class_name => :CompilerSpecGamma)
      eval(compiled).should == "here's some raw text\n"
      
    end
    
  end
  
end # module Walrus

