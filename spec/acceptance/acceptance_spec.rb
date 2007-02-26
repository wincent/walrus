# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  
  class WalrusGrammar
    
    # This spec performs high-level acceptance testing by running Walrus on the sample templates in the subdirectories of the "spec/acceptance/" directory and comparing them with the expected output.
    context 'processing test files with Walrus' do
    
      context_setup do
      
        # construct an array of absolute paths indicating the location of all testable templates.
        @template_paths = Dir[File.join(File.dirname(__FILE__), '**/*.tmpl')].collect { |template| Pathname.new(template).realpath }
      
        # corresponding array of expected output files
        @expected_output_paths = @template_paths.collect { |path| path.to_s.sub(/\.tmpl\z/i, ".expected") }
      
        # class names based on template filename (less ".tmpl" extension)
        @class_names = @template_paths.collect { |path| Pathname.new(path).basename.to_s.gsub(/\.tmpl\z/i, '').to_class_name } 
      
        @parser = Parser.new
      
      end
    
      specify 'actual output should match expected output using "walrus" commandline tool' do
      
      
      end
    
      specify 'actual output should match expected output bypassing "walrus" commandline tool' do
        @template_paths.each_with_index do |template, index|
          actual_output           = self.class.class_eval(@parser.compile(IO.read(template), :class_name => @class_names[index]))
          expected_output         = IO.read(@expected_output_paths[index])
          actual_output.should == expected_output
        end
      
      end
    
    end
    
  end
  
end # module Walrus

