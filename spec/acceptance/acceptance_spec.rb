# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  
  # This spec performs high-level acceptance testing by running Walrus on the sample templates in the subdirectories of the "spec/acceptance/" directory and comparing them with the expected output.
  context 'processing test files with Walrus' do
    
    context_setup do
      
      # construct an array of absolute paths indicating the location of all testable templates.
      @template_paths = Dir[File.join(File.dirname(__FILE__), '**/*.tmpl')].collect { |template| Pathname.new(template).realpath }
      
      # corresponding array of expected output files
      @expected_output_paths = @template_paths.collect { |path| path.sub(/\.tmpl\z/i, ".expected") }
      
      @parser = Parser.new()
      
    end
    
    specify 'actual output should match expected output using "walrus" commandline tool' do
      
      
      
    end
    
    specify 'actual output should match expected output bypassing "walrus" commandline tool' do
      
      @template_paths.each_with_index do |template, index|
        actual_output           = eval(@parser.compile(IO.read(template)))
        expected_output         = IO.read(@expected_output_paths[index])
        actual_output.should == expected_output
      end
      
    end
    
  end
  
end # module Walrus

