# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), 'spec_helper.rb')

module Walrus
  
  context 'compiling' do
    
    context_setup do
      @parser = Parser.new()
    end
    
    specify 'should be able to compile a comment followed by raw text' do
      
      # note that trailing newline is eaten when the comment is the only thing on the newline
      puts @parser.compile("## hello world\nhere's some raw text")
    end
    
    specify 'should be able to compile raw text followed by a comment' do
      
      # on the same line (note that trailing newline is not eaten)
      
      
      # on two separate lines
      
      
    end
    
  end
  
end # module Walrus

